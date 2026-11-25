import 'geez.dart';

/// Turns names written in Latin or Ge'ez script into comparable search keys.
///
/// Two keys are produced, from strict to loose:
///
/// * [phoneticKey] folds spelling variants that sound the same:
///   `Hiwot`, `Heywet`, `Hiywet`, `ሕይወት`, `ሂወት` → `hewet`.
/// * [skeletonKey] keeps only the consonants (plus a leading-vowel marker), to
///   bridge vowels that Latin spellings add or drop: `Birhan` / `ብርሃን`,
///   `Selam` / `Salam`, `Tesfaye` / `ተስፋዬ`.
///
/// Uppercase letters in keys are single-symbol digraphs:
/// S = sh, C = ch, Z = zh, N = ny/gn, T = ts/tz.
abstract final class NameNormalizer {
  /// Lowercase, accents removed, Ge'ez homophones folded (ሐ→ሀ, ሠ→ሰ, …).
  /// Used for "exact" matches and for searching inside meanings.
  static String foldText(String input) =>
      Geez.foldHomophones(_stripDiacritics(input.trim().toLowerCase()));

  static String phoneticKey(String input) {
    String s = _stripDiacritics(input.toLowerCase());
    if (Geez.containsEthiopic(s)) s = Geez.transliterate(s);
    s = s.replaceAll(_nonLetters, '');
    if (s.isEmpty) return s;

    // 1. Digraphs → single symbols, Latin look-alikes → one letter.
    for (final (String from, String to) in _digraphs) {
      s = s.replaceAll(from, to);
    }
    // 2. Long vowels.
    s = s.replaceAll('ou', 'u').replaceAll('oo', 'u').replaceAll('ee', 'i');
    // 3. Diphthongs: "ai" before a consonant is "ay" (Haile = Hayle).
    s = s.replaceAllMapped(_diphthongI, (_) => 'y');
    // 4. ወ is spelled both "we" and "wo" (Wondimu / Wendimu).
    s = s.replaceAll('wo', 'we');
    // 5. Fold vowels that Latin spellings use interchangeably.
    s = s.replaceAll('i', 'e').replaceAll('u', 'o');
    // 6. y: a vowel between consonants (Hywet = Hiwet); silent after a vowel
    //    before a consonant (heywet → hewet) and between e and another vowel
    //    (nuriya → nuria).
    s = s.replaceAll(_yBetweenConsonants, 'e');
    s = s.replaceAll(_ySilentBeforeConsonant, '');
    s = s.replaceAll(_yAfterEBeforeVowel, '');
    // 7. Doubled letters (Hanna = Hana, Abbebe = Abebe).
    s = s.replaceAllMapped(_repeats, (m) => m[1]!);
    return s;
  }

  static String skeletonKey(String input) =>
      skeletonFromPhonetic(phoneticKey(input));

  static String skeletonFromPhonetic(String phonetic) {
    if (phonetic.isEmpty) return phonetic;
    final String first = phonetic[0];
    final String head = _vowels.contains(first) ? 'a' : first;
    return head + phonetic.substring(1).replaceAll(_vowelChars, '');
  }

  // ---------------------------------------------------------------------------

  static const String _vowels = 'aeo';
  static final RegExp _vowelChars = RegExp('[aeo]');
  static final RegExp _nonLetters = RegExp('[^a-zA-Z]');
  static final RegExp _diphthongI = RegExp('(?<=[aeou])i(?![aeiou])');
  static final RegExp _yBetweenConsonants = RegExp('(?<=[^aeoy])y(?=[^aeoy])');
  static final RegExp _ySilentBeforeConsonant = RegExp(
    '(?<=[aeo])y(?=[^aeoy])',
  );
  static final RegExp _yAfterEBeforeVowel = RegExp('(?<=e)y(?=[aeo])');
  static final RegExp _repeats = RegExp(r'(.)\1+');

  /// Order matters: longer / more specific patterns first.
  static const List<(String, String)> _digraphs = [
    ('tz', 'T'),
    ('ts', 'T'),
    ('sh', 'S'),
    ('ch', 'C'),
    ('zh', 'Z'),
    ('ph', 'p'),
    ('kh', 'h'),
    ('gh', 'g'),
    ('gn', 'N'),
    ('ny', 'N'),
    ('ck', 'k'),
    ('q', 'k'),
    ('c', 'k'),
  ];

  static const Map<String, String> _accents = {
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'å': 'a',
    'ā': 'a',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ē': 'e',
    'ə': 'e',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ī': 'i',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ō': 'o',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'ū': 'u',
    'ñ': 'ny',
    'ç': 'c',
    'š': 'sh',
    'č': 'ch',
    'ž': 'zh',
  };

  static String _stripDiacritics(String s) {
    if (!s.runes.any((r) => r > 0x7F)) return s;
    final StringBuffer out = StringBuffer();
    for (final int r in s.runes) {
      final String ch = String.fromCharCode(r);
      out.write(_accents[ch] ?? ch);
    }
    return out.toString();
  }
}
