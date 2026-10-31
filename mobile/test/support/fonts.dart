import 'dart:io';

import 'package:flutter/services.dart';

/// Haqiqiy shriftlarni yuklaydi (aks holda testlarda hamma matn Ahem bilan, juda keng o'lchanadi).
Future<void> loadAppFonts() async {
  const families = {
    'Inter': ['Regular', 'Medium', 'SemiBold', 'Bold'],
    'PlayfairDisplay': ['Medium', 'SemiBold', 'Bold'],
    'IBMPlexSansArabic': ['Regular', 'Medium', 'SemiBold', 'Bold'],
    'Amiri': ['Regular', 'Bold'],
  };
  for (final e in families.entries) {
    final loader = FontLoader(e.key);
    for (final w in e.value) {
      final bytes = File('assets/fonts/${e.key}-$w.ttf').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root != null) {
    final icons = File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    if (icons.existsSync()) {
      final l = FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
      await l.load();
    }
  }
}
