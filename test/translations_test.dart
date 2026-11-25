import 'package:flutter_test/flutter_test.dart';
import 'package:habesha_names/app/translations/am_et.dart';
import 'package:habesha_names/app/translations/app_translations.dart';
import 'package:habesha_names/app/translations/en_us.dart';

void main() {
  test('English and Amharic define exactly the same keys', () {
    final Set<String> en = enUS.keys.toSet();
    final Set<String> am = amET.keys.toSet();
    expect(am.difference(en), isEmpty, reason: 'Keys only in Amharic');
    expect(en.difference(am), isEmpty, reason: 'Keys missing in Amharic');
  });

  test('No translation is blank', () {
    for (final Map<String, String> map in [enUS, amET]) {
      for (final MapEntry<String, String> e in map.entries) {
        expect(e.value.trim(), isNotEmpty, reason: e.key);
      }
    }
  });

  test('Every supported locale has a translation map', () {
    final Map<String, Map<String, String>> keys = AppTranslations().keys;
    for (final locale in AppTranslations.supportedLocales) {
      expect(keys.containsKey(locale.toString()), isTrue, reason: '$locale');
    }
  });

  test('resolve() falls back to English for unknown languages', () {
    expect(AppTranslations.resolve('am'), AppTranslations.amharic);
    expect(AppTranslations.resolve('fr'), AppTranslations.english);
    expect(AppTranslations.resolve(null), AppTranslations.english);
  });
}
