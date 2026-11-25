import 'package:flutter/material.dart';

/// Raw brand colours. Widgets should not read these directly — use
/// `context.colors` (ColorScheme) or `context.palette` (AppPalette) so that
/// light and dark mode stay consistent.
abstract final class AppColors {
  // Brand
  static const Color terracotta = Color(0xFFC8553D);
  static const Color terracottaBright = Color(0xFFE0745C);
  static const Color girl = Color(0xFFE9A6A6);
  static const Color boy = Color(0xFF7FA7C9);
  static const Color unisex = Color(0xFF9DB89A);
  static const Color gold = Color(0xFFD4A24C);

  // Light mode neutrals
  static const Color lightBackground = Color(0xFFFBF7F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFF4EDE5);
  static const Color lightInk = Color(0xFF2B2420);
  static const Color lightInkMuted = Color(0xFF7A6E66);
  static const Color lightOutline = Color(0xFFEAE0D5);
  static const Color lightError = Color(0xFFB3261E);

  // Dark mode neutrals (warm, never pure black)
  static const Color darkBackground = Color(0xFF16110E);
  static const Color darkSurface = Color(0xFF211A16);
  static const Color darkSurfaceMuted = Color(0xFF2C231E);
  static const Color darkInk = Color(0xFFF5EEE6);
  static const Color darkInkMuted = Color(0xFFB3A69B);
  static const Color darkOutline = Color(0xFF3A2F29);
  static const Color darkError = Color(0xFFF2B8B5);
  static const Color darkOnPrimary = Color(0xFF1E1612);
}
