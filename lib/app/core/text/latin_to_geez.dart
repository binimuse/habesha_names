import 'geez.dart';

/// Best-effort Latin → Ge'ez (fidel) transliteration for names that are not
/// in our database, e.g. a father's name typed as "Getachew" → ገታቸው.
///
/// Latin spellings of Amharic are ambiguous (the 1st and 6th vowel orders are
/// both written "e"/"i", homophone letters ሀ/ሐ/ኀ are indistinguishable), so
/// results are approximate and the UI marks them with "≈".
abstract final class LatinToGeez {
  /// Row start code points.
  static const Map<String, int> _consonants = {
    // Digraphs (checked first).
    'sh': 0x1238, 'ch': 0x1278, 'zh': 0x12E0, 'ny': 0x1298, 'gn': 0x1298,
    'ts': 0x1338, 'tz': 0x1338, 'ph': 0x1330, 'kh': 0x12B8,
    // Single letters.
    'h': 0x1200, 'l': 0x1208, 'm': 0x1218, 'r': 0x1228, 's': 0x1230,
    'q': 0x1240, 'b': 0x1260, 'v': 0x1268, 't': 0x1270, 'n': 0x1290,
    'k': 0x12A8, 'c': 0x12A8, 'x': 0x12A8, 'w': 0x12C8, 'z': 0x12D8,
    'y': 0x12E8, 'd': 0x12F0, 'j': 0x1300, 'g': 0x1308, 'p': 0x1350,
    'f': 0x1348,
  };

  static const int _glottal = 0x12A0; // አ

  // Vowel orders.
  static const int _ae = 0, _u = 1, _i = 2, _a = 3, _e = 4, _none = 5, _o = 6;

  static const String _vowelChars = 'aeiou';

  static String convert(String input) => input
      .trim()
      .split(RegExp(r'[\s\-]+'))
      .where((w) => w.isNotEmpty)
      .map(_word)
      .join(' ');

  static String _word(String raw) {
    if (Geez.containsEthiopic(raw)) return raw;
    final String s = _clean(raw);
    final StringBuffer out = StringBuffer();
    int i = 0;
    while (i < s.length) {
      // 1. Consonant (longest match), doubled consonants collapse.
      int? row;
      for (final int len in const [2, 1]) {
        if (i + len <= s.length &&
            _consonants[s.substring(i, i + len)] != null) {
          row = _consonants[s.substring(i, i + len)];
          i += len;
          break;
        }
      }
      if (row != null) {
        while (i < s.length && _consonants[s[i]] == row && !_isVowel(s, i)) {
          i++;
        }
      } else if (!_isVowel(s, i)) {
        i++; // unknown character
        continue;
      }

      // 2. "i" after a vowel before a consonant is the glide ይ (Senait).
      if (row == null &&
          out.isNotEmpty &&
          s[i] == 'i' &&
          _endsSyllable(s, i + 1)) {
        out.writeCharCode(0x12E8 + _none);
        i++;
        continue;
      }

      // 3. Vowel → order.
      final (int order, int used) = _vowel(s, i, row);
      i += used;
      final bool atEnd = i >= s.length;
      int finalOrder = order;
      if (row == 0x12E8 && order == _ae && atEnd) finalOrder = _e; // -ye → ዬ
      if (row == 0x12C8 && order == _o) finalOrder = _ae; // wo → ወ
      out.writeCharCode((row ?? _glottal) + finalOrder);
    }
    return out.toString();
  }

  /// (order, characters consumed) for the vowel at [i].
  static (int, int) _vowel(String s, int i, int? row) {
    if (i >= s.length || !_isVowel(s, i)) return (_none, 0);
    final String two = i + 1 < s.length ? s.substring(i, i + 2) : '';
    switch (two) {
      case 'aa':
        return (_a, 2);
      case 'ee' || 'ie':
        return (_i, 2);
      case 'oo' || 'ou':
        return (_u, 2);
    }
    final bool glottal = row == null;
    switch (s[i]) {
      case 'a':
        return (glottal ? _ae : _a, 1); // አ is already "a"
      case 'e':
        return (glottal ? _e : _ae, 1); // initial / after vowel: ኤ
      case 'u':
        return (_u, 1);
      case 'o':
        return (_o, 1);
      default: // 'i'
        // "i" before a consonant cluster or mid-word is usually the 6th order
        // (Kidist ቅድስት, Birhan ብርሃን); "-it" at the end is ኢ-order (Dawit).
        if (glottal) return (_i, 1);
        final bool finalClosed = i + 2 == s.length && !_isVowel(s, i + 1);
        final bool open = i + 1 >= s.length || _isVowel(s, i + 1);
        return (open || finalClosed ? _i : _none, 1);
    }
  }

  static bool _isVowel(String s, int i) =>
      i < s.length && _vowelChars.contains(s[i]);

  static bool _endsSyllable(String s, int i) =>
      i >= s.length || !_isVowel(s, i);

  static String _clean(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[éèêë]'), 'e')
      .replaceAll(RegExp('[áàâä]'), 'a')
      .replaceAll(RegExp('[^a-z]'), '');
}

/// Ge'ez → readable Latin (for names typed in fidel that are not in our DB).
abstract final class GeezToLatin {
  static String convert(String input) => input
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map((w) {
        final String t = Geez.transliterate(w)
            .replaceAll('S', 'sh')
            .replaceAll('C', 'ch')
            .replaceAll('Z', 'zh')
            .replaceAll('N', 'ny')
            .replaceAll('T', 'ts')
            .replaceAll(RegExp('[^A-Za-z]'), '');
        return t.isEmpty ? t : t[0].toUpperCase() + t.substring(1);
      })
      .join(' ');
}
