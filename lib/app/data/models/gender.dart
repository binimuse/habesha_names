enum Gender {
  boy,
  girl,
  unisex;

  /// Parses `boy` / `girl` / `unisex` (case-insensitive, also `m`/`f`/`u`).
  /// Returns null for anything else.
  static Gender? tryParse(String? raw) {
    switch (raw?.trim().toLowerCase()) {
      case 'boy' || 'male' || 'm':
        return Gender.boy;
      case 'girl' || 'female' || 'f':
        return Gender.girl;
      case 'unisex' || 'u' || 'both':
        return Gender.unisex;
      default:
        return null;
    }
  }
}
