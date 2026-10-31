import 'dart:async';

import 'package:samiya_beauty_lab/features/scanner/text_scanner.dart';

class FakeTextScanner implements TextScanner {
  FakeTextScanner({this.text, this.error, this.available = true});
  String? text; // null = foydalanuvchi bekor qildi
  ScanException? error;
  bool available;
  Completer<String?>? gate;
  final List<ScanSource> calls = [];

  @override
  bool get isAvailable => available;

  @override
  Future<String?> scan(ScanSource source) async {
    calls.add(source);
    if (gate != null) return gate!.future;
    if (error != null) throw error!;
    return text;
  }
}
