import 'package:flutter/material.dart';

/// Qo'llab-quvvatlanadigan tillar: O'zbek, Rus, Ingliz, Arab (RTL).
const supportedLocales = <Locale>[
  Locale('uz'),
  Locale('ru'),
  Locale('en'),
  Locale('ar'),
];

/// Til o'z nomida ko'rsatiladi (hamma tilda bir xil), shuning uchun tarjima kalitlari kerak emas.
const languageNativeNames = <String, String>{
  'uz': 'O‘zbekcha',
  'ru': 'Русский',
  'en': 'English',
  'ar': 'العربية',
};

class LocaleController extends ValueNotifier<Locale> {
  LocaleController([super.initial = const Locale('uz')]);

  void select(String languageCode) {
    assert(languageNativeNames.containsKey(languageCode));
    value = Locale(languageCode);
  }
}
