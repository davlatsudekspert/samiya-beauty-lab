import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_state.dart';
import 'features/auth/auth_service.dart';
import 'features/auth/firebase_auth_service.dart';

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
  runApp(SamiyaApp(state: await AppState.load(auth: await _initAuth())));
}
