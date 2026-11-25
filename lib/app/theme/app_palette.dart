import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Brand colours that do not fit into Material's [ColorScheme]:
/// gender accents, gold highlights, muted text and card shadows.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.girl,
    required this.girlSoft,
    required this.boy,
    required this.boySoft,
    required this.unisex,
    required this.unisexSoft,
    required this.gold,
    required this.goldSoft,
    required this.inkMuted,
    required this.surfaceMuted,
    required this.cardShadow,
  });

  final Color girl;
  final Color girlSoft;
  final Color boy;
  final Color boySoft;
  final Color unisex;
  final Color unisexSoft;
  final Color gold;
  final Color goldSoft;
  final Color inkMuted;
  final Color surfaceMuted;
  final List<BoxShadow> cardShadow;

  static final AppPalette light = AppPalette(
    girl: AppColors.girl,
    girlSoft: _soft(AppColors.girl, AppColors.lightBackground, 0.22),
    boy: AppColors.boy,
    boySoft: _soft(AppColors.boy, AppColors.lightBackground, 0.22),
    unisex: AppColors.unisex,
    unisexSoft: _soft(AppColors.unisex, AppColors.lightBackground, 0.22),
    gold: AppColors.gold,
    goldSoft: _soft(AppColors.gold, AppColors.lightBackground, 0.18),
    inkMuted: AppColors.lightInkMuted,
    surfaceMuted: AppColors.lightSurfaceMuted,
    cardShadow: [
      BoxShadow(
        color: AppColors.lightInk.withValues(alpha: 0.06),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: AppColors.lightInk.withValues(alpha: 0.03),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
  );

  static final AppPalette dark = AppPalette(
    girl: AppColors.girl,
    girlSoft: _soft(AppColors.girl, AppColors.darkSurface, 0.20),
    boy: AppColors.boy,
    boySoft: _soft(AppColors.boy, AppColors.darkSurface, 0.20),
    unisex: AppColors.unisex,
    unisexSoft: _soft(AppColors.unisex, AppColors.darkSurface, 0.20),
    gold: AppColors.gold,
    goldSoft: _soft(AppColors.gold, AppColors.darkSurface, 0.18),
    inkMuted: AppColors.darkInkMuted,
    surfaceMuted: AppColors.darkSurfaceMuted,
    cardShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static Color _soft(Color tint, Color base, double strength) =>
      Color.alphaBlend(tint.withValues(alpha: strength), base);

  @override
  AppPalette copyWith({
    Color? girl,
    Color? girlSoft,
    Color? boy,
    Color? boySoft,
    Color? unisex,
    Color? unisexSoft,
    Color? gold,
    Color? goldSoft,
    Color? inkMuted,
    Color? surfaceMuted,
    List<BoxShadow>? cardShadow,
  }) {
    return AppPalette(
      girl: girl ?? this.girl,
      girlSoft: girlSoft ?? this.girlSoft,
      boy: boy ?? this.boy,
      boySoft: boySoft ?? this.boySoft,
      unisex: unisex ?? this.unisex,
      unisexSoft: unisexSoft ?? this.unisexSoft,
      gold: gold ?? this.gold,
      goldSoft: goldSoft ?? this.goldSoft,
      inkMuted: inkMuted ?? this.inkMuted,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      girl: Color.lerp(girl, other.girl, t)!,
      girlSoft: Color.lerp(girlSoft, other.girlSoft, t)!,
      boy: Color.lerp(boy, other.boy, t)!,
      boySoft: Color.lerp(boySoft, other.boySoft, t)!,
      unisex: Color.lerp(unisex, other.unisex, t)!,
      unisexSoft: Color.lerp(unisexSoft, other.unisexSoft, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldSoft: Color.lerp(goldSoft, other.goldSoft, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      cardShadow: BoxShadow.lerpList(cardShadow, other.cardShadow, t)!,
    );
  }
}
