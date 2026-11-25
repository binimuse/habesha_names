/// Codes used in name data and their translation keys.
/// Labels are looked up as `lang_<code>`, `faith_<code>`, `name_theme_<code>`.
abstract final class Vocabulary {
  static const List<String> languages = ['amharic', 'tigrinya', 'oromo'];

  static const List<String> faiths = [
    'orthodox',
    'protestant',
    'catholic',
    'muslim',
    'neutral',
  ];

  /// Names that are not tied to a faith.
  static const String neutralFaith = 'neutral';

  static String languageKey(String code) => 'lang_$code';
  static String faithKey(String code) => 'faith_$code';
  static String themeKey(String code) => 'name_theme_$code';
}
