import 'package:flutter/material.dart';

import 'app_typography.dart';

/// Brand text styles that are not part of Material's [TextTheme].
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({required this.nameDisplay, required this.nameGeez});

  factory AppTextStyles.fromInk(Color ink) => AppTextStyles(
    nameDisplay: AppTypography.nameDisplay(ink),
    nameGeez: AppTypography.nameGeez(ink),
  );

  /// Large Fraunces title for a name (Latin script).
  final TextStyle nameDisplay;

  /// Noto Serif Ethiopic title for a name (Ge'ez script).
  final TextStyle nameGeez;

  @override
  AppTextStyles copyWith({TextStyle? nameDisplay, TextStyle? nameGeez}) =>
      AppTextStyles(
        nameDisplay: nameDisplay ?? this.nameDisplay,
        nameGeez: nameGeez ?? this.nameGeez,
      );

  @override
  AppTextStyles lerp(ThemeExtension<AppTextStyles>? other, double t) {
    if (other is! AppTextStyles) return this;
    return AppTextStyles(
      nameDisplay: TextStyle.lerp(nameDisplay, other.nameDisplay, t)!,
      nameGeez: TextStyle.lerp(nameGeez, other.nameGeez, t)!,
    );
  }
}
