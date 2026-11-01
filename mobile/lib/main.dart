import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_state.dart';
import 'data/backend_api.dart';
import 'data/install_reporter.dart';
import 'features/auth/auth_service.dart';
import 'features/auth/firebase_auth_service.dart';
import 'data/purchase_service.dart';
import 'features/scanner/mlkit_text_scanner.dart';
import 'features/scanner/text_scanner.dart';

/// Firebase konfiguratsiyasi bo'lsa ulanadi, bo'lmasa kirish halol "mavjud emas" holatida qoladi.
Future<AuthService> _initAuth() async {
  try {
    await Firebase.initializeApp();
    return FirebaseAuthService();
  } catch (_) {
    return const UnavailableAuthService();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const apiBase = String.fromEnvironment('API_BASE_URL');
  final backend = apiBase.isEmpty ? const NoBackendApi() : HttpBackendApi(apiBase);
  runApp(
    SamiyaApp(
      state: await AppState.load(auth: await _initAuth(), backend: backend, scanner: kIsWeb ? const UnavailableTextScanner() : MlkitTextScanner(), purchases: await RevenueCatPurchaseService.create()),
    ),
  );
  // Anonim o'rnatish hisoblagichi (ilova ochilishini kutdirmaydi, xato bo'lsa jim).
  final platform = kIsWeb ? 'web' : (defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android');
  unawaited(
    reportInstall(
      backend,
      platform: platform,
      appVersion: const String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0'),
    ),
  );
}
