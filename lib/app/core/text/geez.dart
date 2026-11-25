/// Helpers for Ethiopic (Ge'ez) script.
///
/// The main Ethiopic block (U+1200–U+137F) is laid out in rows of 8: one row
/// per consonant, one column per vowel "order":
///   0 ä · 1 u · 2 i · 3 a · 4 e · 5 ə/none · 6 o · 7 wa
/// So `row = (cp - 0x1200) ~/ 8` and `order = (cp - 0x1200) % 8`.
abstract final class Geez {
  static const int _start = 0x1200;
  static const int _endSyllables = 0x135A; // last syllable we map
  static const int _punctEnd = 0x137F;

  static bool isEthiopic(int cp) =>
      (cp >= _start && cp <= _punctEnd) ||
      (cp >= 0x1380 && cp <= 0x139F) ||
      (cp >= 0x2D80 && cp <= 0x2DDF);

  static bool isSyllable(int cp) => cp >= _start && cp <= _endSyllables;

  static bool containsEthiopic(String s) => s.runes.any(isEthiopic);

  static int rowOf(int cp) => (cp - _start) ~/ 8;
  static int orderOf(int cp) => (cp - _start) % 8;

  /// First-order (ä) form of a syllable's row, e.g. ሂ → ሀ, ሕ → ሐ.
  /// This is what an alphabet index (ሀ ለ ሐ መ …) groups by.
  static int baseOf(int cp) => isSyllable(cp) ? _start + rowOf(cp) * 8 : cp;

  /// Rows that sound identical in modern Amharic, folded to one row.
  /// ሐ ኀ ኸ → ሀ, ሠ → ሰ, ዐ → አ, ፀ → ጸ.
  static const Map<int, int> _homophoneRow = {
    0x1210: 0x1200, // ሐ → ሀ
    0x1280: 0x1200, // ኀ → ሀ
    0x12B8: 0x1200, // ኸ → ሀ
    0x1220: 0x1230, // ሠ → ሰ
    0x12D0: 0x12A0, // ዐ → አ
    0x1340: 0x1338, // ፀ → ጸ
  };

  /// Replaces each syllable with its homophone-folded equivalent of the same
  /// order (ሕ → ህ, ፀሐይ → ጸሀይ). Non-Ethiopic text is left untouched.
  static String foldHomophones(String s) {
    final StringBuffer out = StringBuffer();
    for (final int cp in s.runes) {
      if (!isSyllable(cp)) {
        out.writeCharCode(cp);
        continue;
      }
      final int base = baseOf(cp);
      final int? folded = _homophoneRow[base];
      out.writeCharCode(folded == null ? cp : folded + orderOf(cp));
    }
    return out.toString();
  }

  // ---------------------------------------------------------------------------
  // Transliteration (for search keys, not for display)
  // ---------------------------------------------------------------------------

  /// Consonant per row (index = row). Uppercase letters are single-symbol
  /// digraphs shared with the Latin normalizer: S=sh, C=ch, Z=zh, N=ny, T=ts.
  /// '' = glottal stop (አ, ዐ). Null = labialised row with its own layout.
  static const List<String?> _rowConsonant = [
    'h', 'l', 'h', 'm', 's', 'r', 's', 'S', // 1200 ሀ ለ ሐ መ ሠ ረ ሰ ሸ
    'k', null, 'k', null, 'b', 'v', 't', 'C', // 1240 ቀ ቈ ቐ ቘ በ ቨ ተ ቸ
    'h', null, 'n', 'N', '', 'k', null, 'h', // 1280 ኀ ኈ ነ ኘ አ ከ ኰ ኸ
    null, 'w', '', 'z', 'Z', 'y', 'd', 'd', // 12C0 ዀ ወ ዐ ዘ ዠ የ ደ ዸ
    'j', 'g', null, 'g', 't', 'C', 'p', 'T', // 1300 ጀ ገ ጐ ጘ ጠ ጨ ጰ ጸ
    'T', 'f', 'p', // 1340 ፀ ፈ ፐ
  ];

  /// Consonant for labialised rows (ቈ ቘ ኈ ኰ ዀ ጐ).
  static const Map<int, String> _labialRowConsonant = {
    9: 'k',
    11: 'k',
    17: 'h',
    22: 'k',
    24: 'h',
    34: 'g',
  };

  /// Rows whose first order is pronounced "a" (ሀ ሐ ኀ ኸ አ ዐ).
  static const Set<int> _gutturalRows = {0, 2, 16, 20, 23, 26};

  static const List<String> _orderVowel = [
    'e',
    'u',
    'i',
    'a',
    'e',
    '',
    'o',
    'wa',
  ];

  /// Approximate Latin reading, e.g. ሕይወት → `heywet`, ፀሐይ → `Tehay`.
  /// Only meant to be fed into the Latin normalizer.
  static String transliterate(String s) {
    final List<int> cps = s.runes.toList();
    final StringBuffer out = StringBuffer();
    String last = '';
    for (int i = 0; i < cps.length; i++) {
      final int cp = cps[i];
      if (!isEthiopic(cp)) {
        out.writeCharCode(cp);
        last = String.fromCharCode(cp);
        continue;
      }
      if (!isSyllable(cp)) {
        out.write(' ');
        last = ' '; // punctuation like ። ፣ or unsupported ranges
        continue;
      }
      final int row = rowOf(cp);
      final int order = orderOf(cp);
      final bool nextIsSyllable = i + 1 < cps.length && isSyllable(cps[i + 1]);
      final String syllable = _syllable(row, order, nextIsSyllable, last);
      out.write(syllable);
      if (syllable.isNotEmpty) last = syllable[syllable.length - 1];
    }
    return out.toString();
  }

  static String _syllable(int row, int order, bool hasNext, String last) {
    final String? labialC = _labialRowConsonant[row];
    if (labialC != null) {
      return switch (order) {
        0 || 4 => '${labialC}we',
        2 => '${labialC}wi',
        3 => '${labialC}wa',
        5 => '${labialC}w',
        _ => labialC,
      };
    }
    final String c = row < _rowConsonant.length ? _rowConsonant[row] ?? '' : '';
    if (order == 0 && _gutturalRows.contains(row)) return '${c}a';
    if (order == 5) return c + _sixthOrderVowel(c, hasNext, last);
    return c + _orderVowel[order];
  }

  /// The 6th order is a short "ə" (written i/e in Latin) or no vowel at all.
  /// Silent at the end of a word, and for y/w right after a vowel (ይ in ሕይወት).
  static String _sixthOrderVowel(String c, bool hasNext, String last) {
    if (!hasNext) return '';
    final bool afterVowel = last.isNotEmpty && 'aeiou'.contains(last);
    if ((c == 'y' || c == 'w') && afterVowel) return '';
    return 'e';
  }
}
