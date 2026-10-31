import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/scanner/inci_parser.dart';

/// Teri turi (foydalanuvchi o'zi belgilaydi; ilova aniqlamaydi).
enum SkinType { dry, oily, combination, normal, sensitive }

/// Kundalikdagi teri holati.
enum SkinFeeling { great, good, okay, dry, irritated }

class RoutineStep {
  const RoutineStep({required this.id, required this.name});
  final String id;
  final String name;
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  factory RoutineStep.fromJson(Map<String, dynamic> j) => RoutineStep(id: j['id'] as String, name: j['name'] as String);
}

class JournalEntry {
  const JournalEntry({required this.id, required this.date, required this.feeling, this.note = ''});
  final String id;
  final DateTime date;
  final SkinFeeling feeling;
  final String note;
  Map<String, dynamic> toJson() => {'id': id, 'date': date.toIso8601String(), 'feeling': feeling.name, 'note': note};
  factory JournalEntry.fromJson(Map<String, dynamic> j) => JournalEntry(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        feeling: SkinFeeling.values.where((f) => f.name == j['feeling']).firstOrNull ?? SkinFeeling.okay,
        note: (j['note'] as String?) ?? '',
      );
}

/// Shaxsiy ma'lumotlar (teri afzalliklari, parvarish rejasi, kundalik): FAQAT qurilmada saqlanadi.
class PersonalStore extends ChangeNotifier {
  PersonalStore({DateTime Function()? clock, this.persist = true}) : _clock = clock ?? DateTime.now;

  static const _key = 'personal_v1';
  static const maxAvoid = 100, maxSteps = 15, maxJournal = 1000, maxText = 300;

  final DateTime Function() _clock;
  final bool persist;

  SkinType? skinType;
  final List<String> avoid = [];
  final Map<String, List<RoutineStep>> routine = {'am': [], 'pm': []};
  final Map<String, String> _doneOn = {}; // qadam id -> yyyy-mm-dd
  final List<JournalEntry> journal = [];

  DateTime now() => _clock();

  String get _today {
    final d = _clock();
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static String _id() => List.generate(12, (_) => Random.secure().nextInt(16).toRadixString(16)).join();
  static String _clean(String s) => s.trim().replaceAll(RegExp(r'\s+'), ' ').characters.take(maxText).toString();

  static Future<PersonalStore> load({DateTime Function()? clock}) async {
    final s = PersonalStore(clock: clock);
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    if (raw == null) return s;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      s.skinType = SkinType.values.where((t) => t.name == j['skinType']).firstOrNull;
      s.avoid.addAll(List<String>.from((j['avoid'] as List?) ?? const []));
      for (final slot in ['am', 'pm']) {
        s.routine[slot]!.addAll([
          for (final r in ((j['routine'] as Map?)?[slot] as List?) ?? const []) RoutineStep.fromJson(Map<String, dynamic>.from(r as Map)),
        ]);
      }
      s._doneOn.addAll(Map<String, String>.from((j['doneOn'] as Map?) ?? const {}));
      s.journal.addAll([for (final e in (j['journal'] as List?) ?? const []) JournalEntry.fromJson(Map<String, dynamic>.from(e as Map))]);
    } catch (_) {
      // buzilgan ma'lumot: bo'sh holatdan boshlanadi (ilova yiqilmaydi)
    }
    return s;
  }

  Future<void> _save() async {
    notifyListeners();
    if (!persist) return;
    await (await SharedPreferences.getInstance()).setString(
      _key,
      jsonEncode({
        'skinType': skinType?.name,
        'avoid': avoid,
        'routine': {for (final e in routine.entries) e.key: [for (final s in e.value) s.toJson()]},
        'doneOn': _doneOn,
        'journal': [for (final e in journal) e.toJson()],
      }),
    );
  }

  Future<void> setSkinType(SkinType? t) {
    skinType = t;
    return _save();
  }

  /// Qo'shildi bo'lsa true (bo'sh, takror yoki chegara oshsa false).
  Future<bool> addAvoid(String name) async {
    final n = _clean(name);
    if (n.isEmpty || avoid.length >= maxAvoid || avoid.any((a) => inciKey(a) == inciKey(n))) return false;
    avoid.add(n);
    await _save();
    return true;
  }

  Future<void> removeAvoid(String name) {
    avoid.removeWhere((a) => a == name);
    return _save();
  }

  /// Tarkibdagi nomlardan qaysilari foydalanuvchining "chetlab o'tish" ro'yxatida (aniq nom bo'yicha).
  List<String> avoidHits(Iterable<String> names) {
    final keys = {for (final a in avoid) inciKey(a)};
    return [for (final n in names) if (keys.contains(inciKey(n))) n];
  }

  Future<bool> addStep(String slot, String name) async {
    final n = _clean(name);
    final list = routine[slot]!;
    if (n.isEmpty || list.length >= maxSteps) return false;
    list.add(RoutineStep(id: _id(), name: n));
    await _save();
    return true;
  }

  Future<void> removeStep(String slot, String id) {
    routine[slot]!.removeWhere((s) => s.id == id);
    _doneOn.remove(id);
    return _save();
  }

  Future<void> moveStep(String slot, int index, int delta) async {
    final list = routine[slot]!;
    final to = index + delta;
    if (index < 0 || index >= list.length || to < 0 || to >= list.length) return;
    final s = list.removeAt(index);
    list.insert(to, s);
    await _save();
  }

  bool isDoneToday(String id) => _doneOn[id] == _today;
  int doneToday(String slot) => routine[slot]!.where((s) => isDoneToday(s.id)).length;

  Future<void> toggleDone(String id) {
    if (isDoneToday(id)) {
      _doneOn.remove(id);
    } else {
      _doneOn[id] = _today;
    }
    return _save();
  }

  Future<void> addJournal(SkinFeeling feeling, String note) async {
    journal.insert(0, JournalEntry(id: _id(), date: _clock(), feeling: feeling, note: _clean(note)));
    if (journal.length > maxJournal) journal.removeRange(maxJournal, journal.length);
    await _save();
  }

  Future<void> removeJournal(String id) {
    journal.removeWhere((e) => e.id == id);
    return _save();
  }

  /// Hisob o'chirilganda yoki foydalanuvchi so'raganda: hammasini tozalash.
  Future<void> clear() {
    skinType = null;
    avoid.clear();
    for (final l in routine.values) {
      l.clear();
    }
    _doneOn.clear();
    journal.clear();
    return _save();
  }
}
