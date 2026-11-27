import 'package:flutter/material.dart';

import '../data/admin_name.dart';

/// Habesha Names palette, plain Material 3 for a dense admin UI.
abstract final class AdminColors {
  static const Color terracotta = Color(0xFFC8553D);
  static const Color girl = Color(0xFFE9A6A6);
  static const Color boy = Color(0xFF7FA7C9);
  static const Color unisex = Color(0xFF9DB89A);
  static const Color gold = Color(0xFFD4A24C);
  static const Color background = Color(0xFFFBF7F2);
  static const Color ink = Color(0xFF2B2420);

  static Color gender(String g) => switch (g) {
    'girl' => girl,
    'boy' => boy,
    _ => unisex,
  };
}

abstract final class AdminTheme {
  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AdminColors.terracotta,
      primary: AdminColors.terracotta,
      surface: Colors.white,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: AdminColors.background,
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

/// Colour + label for a name's publish status (list chips, edit banner).
abstract final class StatusColors {
  static Color of(NameStatus? s) => switch (s) {
    NameStatus.published => const Color(0xFF4E8A57),
    NameStatus.changed => AdminColors.gold,
    NameStatus.draft => const Color(0xFF6E7F99),
    NameStatus.deleted => const Color(0xFF9E9E9E),
    null => AdminColors.terracotta,
  };

  static String label(NameStatus s) => switch (s) {
    NameStatus.published => 'Published',
    NameStatus.changed => 'Unpublished changes',
    NameStatus.draft => 'Draft',
    NameStatus.deleted => 'Deleted',
  };
}
