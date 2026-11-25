import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'am_et.dart';
import 'en_us.dart';

class AppTranslations extends Translations {
  static const Locale english = Locale('en', 'US');
  static const Locale amharic = Locale('am', 'ET');

  static const Locale fallbackLocale = english;
  static const List<Locale> supportedLocales = [english, amharic];

  /// Returns the supported locale matching [languageCode], or the fallback.
  static Locale resolve(String? languageCode) => supportedLocales.firstWhere(
    (l) => l.languageCode == languageCode,
    orElse: () => fallbackLocale,
  );

  @override
  Map<String, Map<String, String>> get keys => const {
    'en_US': enUS,
    'am_ET': amET,
  };
}
