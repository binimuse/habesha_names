import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../routes/app_pages.dart';
import '../../../services/notifications_service.dart';
import '../../../services/purchase_service.dart';
import '../../../services/settings_service.dart';
import '../../premium/controllers/premium_controller.dart';
import '../../onboarding/controllers/onboarding_controller.dart';
import '../../../translations/app_translations.dart';
import '../../../translations/locale_keys.dart';

class SettingsController extends GetxController {
  SettingsController(this._settings);

  final SettingsService _settings;

  Rx<ThemeMode> get themeMode => _settings.themeMode;
  Rx<Locale> get locale => _settings.locale;

  List<Locale> get locales => AppTranslations.supportedLocales;

  /// Translation key for a theme mode's label.
  String themeModeLabelKey(ThemeMode mode) => switch (mode) {
    ThemeMode.system => LocaleKeys.themeSystem,
    ThemeMode.light => LocaleKeys.themeLight,
    ThemeMode.dark => LocaleKeys.themeDark,
  };

  /// Translation key for a locale's label (shown in its own script).
  String localeLabelKey(Locale value) => value.languageCode == 'am'
      ? LocaleKeys.languageAmharic
      : LocaleKeys.languageEnglish;

  Future<void> setThemeMode(ThemeMode mode) => _settings.setThemeMode(mode);

  Future<void> setLocale(Locale value) => _settings.setLocale(value);

  void editPreferences() =>
      Get.toNamed<void>(Routes.onboarding, arguments: OnboardingMode.edit);

  // Notifications ---------------------------------------------------------------

  bool get dailyName =>
      Get.isRegistered<NotificationsService>() &&
      Get.find<NotificationsService>().dailyEnabled.value;

  Future<void> setDailyName(bool on) async {
    if (Get.isRegistered<NotificationsService>()) {
      await Get.find<NotificationsService>().setDaily(on);
    }
  }

  // About ------------------------------------------------------------------------

  Future<void> openPrivacy() => _open(AppLinks.privacy);

  /// Google Play's in-app review sheet; falls back to the store listing.
  Future<void> rateApp() async {
    final InAppReview review = InAppReview.instance;
    try {
      if (await review.isAvailable()) {
        await review.requestReview();
        return;
      }
    } catch (_) {}
    await _open(AppLinks.playStore);
  }

  Future<void> _open(String url) async {
    final bool ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    ).catchError((Object _) => false);
    if (!ok) PremiumController.toast(LocaleKeys.settingsLinkFailed.tr);
  }

  // Premium ---------------------------------------------------------------------

  bool get isPremium =>
      Get.isRegistered<PurchaseService>() &&
      Get.find<PurchaseService>().isPremium.value;

  void openPremium() => Get.toNamed<void>(Routes.premium);

  Future<void> restorePurchases() async {
    if (!Get.isRegistered<PurchaseService>()) return;
    final RestoreResult r = await Get.find<PurchaseService>().restore();
    PremiumController.toast(switch (r) {
      RestoreResult.restored => LocaleKeys.premiumRestored.tr,
      RestoreResult.nothing => LocaleKeys.premiumNothingToRestore.tr,
      RestoreResult.unavailable => LocaleKeys.premiumUnavailable.tr,
    });
  }
}
