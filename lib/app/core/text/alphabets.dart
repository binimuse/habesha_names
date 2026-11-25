/// Letters for the browse index.
abstract final class Alphabets {
  static final List<String> latin = [
    for (int c = 0x41; c <= 0x5A; c++) String.fromCharCode(c),
  ];

  /// Amharic fidel base letters in traditional order (ሀ ለ ሐ … ፐ).
  static const List<String> geez = [
    'ሀ', 'ለ', 'ሐ', 'መ', 'ሠ', 'ረ', 'ሰ', 'ሸ', 'ቀ', 'በ', 'ቨ', 'ተ', 'ቸ', //
    'ኀ', 'ነ', 'ኘ', 'አ', 'ከ', 'ኸ', 'ወ', 'ዐ', 'ዘ', 'ዠ', 'የ', 'ደ', 'ጀ',
    'ገ', 'ጠ', 'ጨ', 'ጰ', 'ጸ', 'ፀ', 'ፈ', 'ፐ',
  ];
}
