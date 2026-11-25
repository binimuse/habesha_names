import 'package:get/get.dart';

import '../../data/models/gender.dart';
import '../../data/models/name_model.dart';
import '../../data/models/vocabulary.dart';
import '../../translations/locale_keys.dart';

/// Translated labels for data codes, with a readable fallback for codes that
/// have no translation yet (new themes added on the server).
abstract final class Labels {
  static bool get isAmharic => Get.locale?.languageCode == 'am';

  static String language(String code) =>
      _orTitle(Vocabulary.languageKey(code), code);

  static String faith(String code) => _orTitle(Vocabulary.faithKey(code), code);

  static String theme(String code) => _orTitle(Vocabulary.themeKey(code), code);

  static String gender(Gender g) => switch (g) {
    Gender.boy => LocaleKeys.genderBoy.tr,
    Gender.girl => LocaleKeys.genderGirl.tr,
    Gender.unisex => LocaleKeys.genderUnisex.tr,
  };

  /// Meaning in the UI language, falling back to the other one.
  static String meaning(NameModel n) =>
      _pick(primaryAm: n.meaningAm, primaryEn: n.meaningEn);

  /// The meaning in the *other* language (shown as a secondary line).
  static String secondaryMeaning(NameModel n) {
    final String other = isAmharic ? n.meaningEn : n.meaningAm;
    return other == meaning(n) ? '' : other;
  }

  static String origin(NameModel n) =>
      _pick(primaryAm: n.originAm, primaryEn: n.originEn);

  static String _pick({required String primaryAm, required String primaryEn}) {
    final String first = isAmharic ? primaryAm : primaryEn;
    return first.isNotEmpty ? first : (isAmharic ? primaryEn : primaryAm);
  }

  static String _orTitle(String key, String code) {
    final String t = key.tr;
    if (t != key) return t;
    return code.isEmpty ? code : code[0].toUpperCase() + code.substring(1);
  }
}
