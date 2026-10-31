import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'backend_api.dart';

const _key = 'install_id';

String _newId() {
  final r = Random.secure();
  return List.generate(32, (_) => r.nextInt(16).toRadixString(16)).join();
}

/// Anonim o'rnatish hisoblagichi: tasodifiy ID (qurilma yoki shaxsga bog'lanmagan) bir marta yaratiladi
/// va har ochilishda yuboriladi. Xato bo'lsa ilova ishiga ta'sir qilmaydi.
Future<void> reportInstall(BackendApi backend, {required String platform, required String appVersion}) async {
  if (!backend.isConfigured) return;
  try {
    final p = await SharedPreferences.getInstance();
    var id = p.getString(_key);
    if (id == null || id.length < 16) {
      id = _newId();
      await p.setString(_key, id);
    }
    await backend.recordInstall(installId: id, platform: platform, appVersion: appVersion);
  } catch (_) {
    // hisoblagich muhim emas: jim o'tkazib yuboramiz
  }
}
