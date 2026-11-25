import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds the app's text styles.
///
/// Fonts are bundled in `assets/google_fonts/` and runtime fetching is
/// disabled, so only the weights below may be requested:
/// - Plus Jakarta Sans:   400, 500, 600, 700 (UI, Latin)
/// - Fraunces:            600                (display, Latin)
/// - Noto Sans Ethiopic:  400, 500, 600, 700 (UI, Ge'ez)
/// - Noto Serif Ethiopic: 600, 700           (display; 700 = app logo)
abstract final class AppTypography {
  static TextTheme textTheme({
    required Locale locale,
    required Color ink,
    required Color inkMuted,
  }) {
    final bool geezFirst = locale.languageCode == 'am';

    TextStyle ui(
      double size,
      FontWeight weight, {
      double height = 1.35,
      double spacing = 0,
      Color? color,
    }) => _ui(
      size: size,
      weight: weight,
      height: geezFirst ? height + 0.1 : height,
      spacing: spacing,
      color: color ?? ink,
      geezFirst: geezFirst,
    );

    TextStyle display(double size, {double spacing = -0.5}) => _display(
      size: size,
      weight: FontWeight.w600,
      height: 1.15,
      spacing: geezFirst ? 0 : spacing,
      color: ink,
      geezFirst: geezFirst,
    );

    return TextTheme(
      displayLarge: display(48, spacing: -1),
      displayMedium: display(40, spacing: -0.8),
      displaySmall: display(32),
      headlineLarge: display(28),
      headlineMedium: ui(24, FontWeight.w700, spacing: -0.3),
      headlineSmall: ui(20, FontWeight.w700, spacing: -0.2),
      titleLarge: ui(18, FontWeight.w700),
      titleMedium: ui(16, FontWeight.w600),
      titleSmall: ui(14, FontWeight.w600),
      bodyLarge: ui(16, FontWeight.w400, height: 1.5),
      bodyMedium: ui(14, FontWeight.w400, height: 1.5),
      bodySmall: ui(12, FontWeight.w400, height: 1.45, color: inkMuted),
      labelLarge: ui(14, FontWeight.w600, spacing: 0.1),
      labelMedium: ui(12, FontWeight.w600, spacing: 0.2),
      labelSmall: ui(11, FontWeight.w500, spacing: 0.3),
    );
  }

  /// Big serif style for a name in Latin script (e.g. "Abebech").
  static TextStyle nameDisplay(Color color) => _display(
    size: 44,
    weight: FontWeight.w600,
    height: 1.1,
    spacing: -1,
    color: color,
    geezFirst: false,
  );

  /// Ge'ez-script style for a name (e.g. "አበበች").
  static TextStyle nameGeez(Color color) => _display(
    size: 30,
    weight: FontWeight.w600,
    height: 1.3,
    spacing: 0,
    color: color,
    geezFirst: true,
  );

  // ---------------------------------------------------------------------------

  static TextStyle _ui({
    required double size,
    required FontWeight weight,
    required double height,
    required double spacing,
    required Color color,
    required bool geezFirst,
  }) {
    final TextStyle latin = GoogleFonts.plusJakartaSans(fontWeight: weight);
    final TextStyle geez = GoogleFonts.notoSansEthiopic(
      fontWeight: _geezSansWeight(weight),
    );
    return _compose(
      primary: geezFirst ? geez : latin,
      fallback: geezFirst ? latin : geez,
      size: size,
      height: height,
      spacing: spacing,
      color: color,
    );
  }

  static TextStyle _display({
    required double size,
    required FontWeight weight,
    required double height,
    required double spacing,
    required Color color,
    required bool geezFirst,
  }) {
    final TextStyle latin = GoogleFonts.fraunces(
      fontWeight: _serifWeight(weight),
    );
    final TextStyle geez = GoogleFonts.notoSerifEthiopic(
      fontWeight: _serifWeight(weight),
    );
    return _compose(
      primary: geezFirst ? geez : latin,
      fallback: geezFirst ? latin : geez,
      size: size,
      height: height,
      spacing: spacing,
      color: color,
    );
  }

  /// Uses [primary]'s family and falls back to [fallback] for glyphs it lacks,
  /// so mixed Latin / Ge'ez strings always render in a brand font.
  static TextStyle _compose({
    required TextStyle primary,
    required TextStyle fallback,
    required double size,
    required double height,
    required double spacing,
    required Color color,
  }) {
    return primary.copyWith(
      fontSize: size,
      height: height,
      letterSpacing: spacing,
      color: color,
      fontFamilyFallback: [
        if (fallback.fontFamily != null) fallback.fontFamily!,
      ],
    );
  }

  static FontWeight _geezSansWeight(FontWeight w) =>
      w.value > 700 ? FontWeight.w700 : w;

  static FontWeight _serifWeight(FontWeight w) {
    if (w.value >= 700) return FontWeight.w700;
    if (w.value >= 550) return FontWeight.w600;
    return FontWeight.w400;
  }
}
