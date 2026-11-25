import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_palette.dart';
import 'app_text_styles.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData light(Locale locale) =>
      _build(brightness: Brightness.light, locale: locale);

  static ThemeData dark(Locale locale) =>
      _build(brightness: Brightness.dark, locale: locale);

  static ThemeData _build({
    required Brightness brightness,
    required Locale locale,
  }) {
    final bool isDark = brightness == Brightness.dark;
    final AppPalette palette = isDark ? AppPalette.dark : AppPalette.light;
    final ColorScheme scheme = isDark ? _darkScheme : _lightScheme;
    final Color background = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final TextTheme text = AppTypography.textTheme(
      locale: locale,
      ink: scheme.onSurface,
      inkMuted: palette.inkMuted,
    );

    final RoundedRectangleBorder mdShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      extensions: [palette, AppTextStyles.fromInk(scheme.onSurface)],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.headlineSmall,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelMedium!.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : palette.inkMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : palette.inkMuted,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: mdShape,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: mdShape,
          side: BorderSide(color: scheme.outline),
          foregroundColor: scheme.onSurface,
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: mdShape, textStyle: text.labelLarge),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: scheme.onSurface),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: mdShape,
          side: BorderSide(color: scheme.outline),
          selectedBackgroundColor: scheme.primary.withValues(alpha: 0.14),
          selectedForegroundColor: scheme.primary,
          textStyle: text.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        hintStyle: text.bodyLarge!.copyWith(color: palette.inkMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: _inputBorder(scheme.outline),
        enabledBorder: _inputBorder(scheme.outline),
        focusedBorder: _inputBorder(scheme.primary, width: 1.5),
        errorBorder: _inputBorder(scheme.error),
        focusedErrorBorder: _inputBorder(scheme.error, width: 1.5),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        backgroundColor: palette.surfaceMuted,
        selectedColor: scheme.primary.withValues(alpha: 0.14),
        labelStyle: text.labelLarge,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: mdShape,
        iconColor: palette.inkMuted,
        titleTextStyle: text.titleMedium,
        subtitleTextStyle: text.bodySmall,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        circularTrackColor: scheme.primary.withValues(alpha: 0.12),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium!.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: mdShape,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: color, width: width),
      );

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.terracotta,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFF6DCD5),
    onPrimaryContainer: Color(0xFF5A1F12),
    secondary: AppColors.gold,
    onSecondary: AppColors.lightInk,
    secondaryContainer: Color(0xFFF6E8CC),
    onSecondaryContainer: Color(0xFF4A3510),
    tertiary: AppColors.unisex,
    onTertiary: AppColors.lightInk,
    error: AppColors.lightError,
    onError: Colors.white,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightInk,
    onSurfaceVariant: AppColors.lightInkMuted,
    surfaceContainerLowest: AppColors.lightSurface,
    surfaceContainerLow: AppColors.lightSurface,
    surfaceContainer: AppColors.lightSurfaceMuted,
    surfaceContainerHigh: AppColors.lightSurfaceMuted,
    surfaceContainerHighest: Color(0xFFEDE4DA),
    outline: AppColors.lightOutline,
    outlineVariant: Color(0xFFF1EAE2),
    shadow: AppColors.lightInk,
    inverseSurface: AppColors.lightInk,
    onInverseSurface: AppColors.lightBackground,
    inversePrimary: AppColors.terracottaBright,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.terracottaBright,
    onPrimary: AppColors.darkOnPrimary,
    primaryContainer: Color(0xFF5A2618),
    onPrimaryContainer: Color(0xFFFFDAD1),
    secondary: AppColors.gold,
    onSecondary: AppColors.darkOnPrimary,
    secondaryContainer: Color(0xFF4A3812),
    onSecondaryContainer: Color(0xFFF6E2B8),
    tertiary: AppColors.unisex,
    onTertiary: AppColors.darkOnPrimary,
    error: AppColors.darkError,
    onError: Color(0xFF601410),
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkInk,
    onSurfaceVariant: AppColors.darkInkMuted,
    surfaceContainerLowest: AppColors.darkBackground,
    surfaceContainerLow: AppColors.darkSurface,
    surfaceContainer: AppColors.darkSurfaceMuted,
    surfaceContainerHigh: AppColors.darkSurfaceMuted,
    surfaceContainerHighest: Color(0xFF362B25),
    outline: AppColors.darkOutline,
    outlineVariant: Color(0xFF2E2520),
    shadow: Colors.black,
    inverseSurface: AppColors.darkInk,
    onInverseSurface: AppColors.darkBackground,
    inversePrimary: AppColors.terracotta,
  );
}
