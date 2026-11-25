import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_text_styles.dart';

/// Theme shortcuts. GetX already provides `context.theme`,
/// `context.textTheme` and `context.isDarkMode`, so they are not redefined.
extension ThemeContextX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
  AppTextStyles get appText => Theme.of(this).extension<AppTextStyles>()!;
}
