import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SamiyaApp(state: await AppState.load()));
}
