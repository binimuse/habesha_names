import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habesha_names/app/theme/app_palette.dart';
import 'package:habesha_names/app/theme/app_text_styles.dart';
import 'package:habesha_names/app/theme/app_theme.dart';
import 'package:habesha_names/app/translations/app_translations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  for (final Locale locale in AppTranslations.supportedLocales) {
    testWidgets('light & dark themes build for $locale using bundled fonts', (
      tester,
    ) async {
      for (final ThemeData theme in [
        AppTheme.light(locale),
        AppTheme.dark(locale),
      ]) {
        expect(theme.extension<AppPalette>(), isNotNull);
        expect(theme.extension<AppTextStyles>(), isNotNull);
        expect(theme.textTheme.bodyMedium!.fontFamilyFallback, isNotEmpty);
      }
      // Fails if any requested weight is missing from assets/google_fonts.
      await tester.runAsync(GoogleFonts.pendingFonts);
    });
  }
}
