/// Allowed codes — must match the app's Vocabulary / Gender / Rarity.
abstract final class Vocab {
  static const List<String> genders = ['boy', 'girl', 'unisex'];
  static const List<String> languages = ['amharic', 'tigrinya', 'oromo'];
  static const List<String> faiths = [
    'orthodox',
    'protestant',
    'catholic',
    'muslim',
    'neutral',
  ];
  static const List<String> themes = [
    'nature',
    'faith',
    'peace',
    'love',
    'light',
    'hope',
    'strength',
    'joy',
    'life',
    'virtue',
    'history',
  ];
}

/// "Abebe Bikila" → "abebe-bikila"; used as the Firestore doc id.
String slugify(String latin) => latin
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r"[’'`]"), '')
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');
