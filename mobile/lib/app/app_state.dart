import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../features/scanner/ingredient_models.dart';

/// Qo'llab-quvvatlanadigan tillar: O'zbek, Rus, Ingliz, Arab (RTL).
const supportedLocales = <Locale>[Locale('uz'), Locale('ru'), Locale('en'), Locale('ar')];

/// Til o'z nomida ko'rsatiladi (hamma tilda bir xil), tarjima kalitlari kerak emas.
const languageNativeNames = <String, String>{
  'uz': 'O‘zbekcha',
  'ru': 'Русский',
  'en': 'English',
  'ar': 'العربية',
};

enum UserRole { user, student, cosmetologist, teacher }

// Named parametrlar private maydonga `this._x` bilan bog'lanmaydi (Dart cheklovi).
// ignore_for_file: prefer_initializing_formals

/// Ilovaning global holati: til, onboarding tugaganmi, rol. Diskda saqlanadi.
class AppState extends ChangeNotifier {
  AppState({
    Locale locale = const Locale('uz'),
    bool onboarded = false,
    UserRole? role,
    IngredientRepository? ingredients,
  })  : ingredients = ingredients ?? IngredientRepository(const []),
        _locale = locale,
        _onboarded = onboarded,
        _role = role;

  /// Ingredient bazasi (assets/content/ingredients.json), o'zgarmas.
  final IngredientRepository ingredients;

  Locale _locale;
  bool _onboarded;
  UserRole? _role;

  Locale get locale => _locale;
  bool get onboarded => _onboarded;
  UserRole? get role => _role;

  static Future<AppState> load() async {
    final p = await SharedPreferences.getInstance();
    final code = p.getString('locale');
    final roleName = p.getString('role');
    final repo = IngredientRepository.fromJson(await rootBundle.loadString('assets/content/ingredients.json'));
    return AppState(
      ingredients: repo,
      locale: Locale(languageNativeNames.containsKey(code) ? code! : 'uz'),
      onboarded: p.getBool('onboarded') ?? false,
      role: UserRole.values.where((r) => r.name == roleName).firstOrNull,
    );
  }

  Future<void> setLocale(String code) async {
    assert(languageNativeNames.containsKey(code));
    _locale = Locale(code);
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString('locale', code);
  }

  Future<void> setRole(UserRole role) async {
    _role = role;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString('role', role.name);
  }

  Future<void> completeOnboarding() async {
    _onboarded = true;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setBool('onboarded', true);
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
