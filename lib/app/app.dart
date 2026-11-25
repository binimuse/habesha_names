import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'routes/app_pages.dart';
import 'services/settings_service.dart';
import 'theme/app_dimens.dart';
import 'theme/app_theme.dart';
import 'translations/app_translations.dart';
import 'translations/locale_keys.dart';

class HabeshaNamesApp extends StatelessWidget {
  const HabeshaNamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsService settings = Get.find<SettingsService>();

    // Rebuilds when theme mode or language changes. The locale also selects
    // the primary font (Plus Jakarta Sans vs. Noto Sans Ethiopic).
    return Obx(() {
      final Locale locale = settings.locale.value;
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (_) => LocaleKeys.appName.tr,
        translations: AppTranslations(),
        locale: locale,
        fallbackLocale: AppTranslations.fallbackLocale,
        supportedLocales: AppTranslations.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: AppTheme.light(locale),
        darkTheme: AppTheme.dark(locale),
        themeMode: settings.themeMode.value,
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        defaultTransition: Transition.native,
        transitionDuration: AppDurations.medium,
      );
    });
  }
}
