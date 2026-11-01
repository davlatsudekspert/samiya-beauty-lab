// Avtomatik ro'yxat: assets/botanical/ dagi gravyuralar (Franz Eugen Köhler, "Köhler's Medizinal-Pflanzen", 1887; jamoat mulki).
// Rasm qo'shilganda shu ro'yxatga slug yoziladi.
import 'package:flutter/widgets.dart';

const botanicalSlugs = <String>{'aloe-vera'};

/// Doira ichida o'simlikning eng chiroyli qismi ko'rinsin: kattalashtirish va markaz.
const botanicalFocus = <String, (double, Alignment)>{
  'aloe-vera': (1.9, Alignment(0.0, -0.35)),
};

/// Fotosuratlar (iNaturalist, CC0 1.0 — "huquqlar saqlanmagan"); manbalar: assets/photos/CREDITS.json.
const photoSlugs = <String>{
  'aloe-vera', 'banana', 'chamomile', 'coconut-oil', 'cucumber', 'green-tea',
  'honey', 'lemon-juice', 'oat', 'olive-oil', 'rosehip-oil', 'turmeric', 'rose-water',
};

/// Foto doirada: markaz nuqtasi (asosiy obyekt ko'rinsin).
const photoFocus = <String, Alignment>{
  'aloe-vera': Alignment(-0.3, -0.2),
  'banana': Alignment(0.2, -0.3),
  'chamomile': Alignment(0.0, -0.3),
  'cucumber': Alignment(0.3, 0.0),
  'green-tea': Alignment(0.3, -0.2),
  'honey': Alignment(-0.3, -0.1),
  'lemon-juice': Alignment(-0.5, 0.3),
  'olive-oil': Alignment(0.2, 0.0),
  'rosehip-oil': Alignment(0.3, -0.3),
  'turmeric': Alignment(0.1, -0.3),
  'rose-water': Alignment(0.0, -0.4),
};

String? ingredientImage(String slug) => photoSlugs.contains(slug)
    ? 'assets/photos/$slug.jpg'
    : botanicalSlugs.contains(slug)
        ? 'assets/botanical/$slug.jpg'
        : null;
