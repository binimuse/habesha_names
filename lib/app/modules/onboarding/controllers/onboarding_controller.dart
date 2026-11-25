import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../data/models/user_prefs.dart';
import '../../../data/models/vocabulary.dart';
import '../../../routes/app_pages.dart';
import '../../../services/notifications_service.dart';
import '../../../services/preferences_service.dart';
import '../../../services/settings_service.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/app_translations.dart';

/// Pass as route arguments to edit preferences from Settings.
enum OnboardingMode { firstRun, edit }

class OnboardingController extends GetxController {
  OnboardingController(this._settings, this._prefs);

  static const int pageCount = 3;

  final SettingsService _settings;
  final PreferencesService _prefs;

  /// Opened from Settings: no Skip, "Save" returns to the previous page.
  final bool editing = Get.arguments == OnboardingMode.edit;

  final PageController pageController = PageController();
  final RxInt page = 0.obs;
  final Rx<Expecting> expecting = Expecting.unknown.obs;
  final RxSet<String> faiths = <String>{}.obs;
  final RxSet<String> languages = <String>{}.obs;

  List<Locale> get locales => AppTranslations.supportedLocales;
  Rx<Locale> get locale => _settings.locale;
  List<String> get faithOptions => Vocabulary.faiths
      .where((f) => f != Vocabulary.neutralFaith)
      .toList(growable: false);
  List<String> get languageOptions => Vocabulary.languages;

  bool get isLastPage => page.value == pageCount - 1;

  @override
  void onInit() {
    super.onInit();
    final UserPrefs saved = _prefs.prefs.value;
    expecting.value = saved.expecting;
    faiths.addAll(saved.faiths);
    languages.addAll(saved.languages);
  }

  void onPageChanged(int index) => page.value = index;

  Future<void> setLocale(Locale value) => _settings.setLocale(value);

  void setExpecting(Expecting value) => expecting.value = value;

  void toggleFaith(String code) =>
      faiths.contains(code) ? faiths.remove(code) : faiths.add(code);

  void toggleLanguage(String code) =>
      languages.contains(code) ? languages.remove(code) : languages.add(code);

  Future<void> next() async {
    if (isLastPage) return finish();
    await pageController.nextPage(
      duration: AppDurations.medium,
      curve: AppCurves.standard,
    );
  }

  bool get canGoBack => page.value > 0 || editing;

  /// Previous slide, or close the editor from the first slide.
  Future<void> goBack() async {
    if (page.value > 0) return back();
    if (editing) Get.back<void>();
  }

  Future<void> back() => pageController.previousPage(
    duration: AppDurations.medium,
    curve: AppCurves.standard,
  );

  Future<void> finish() async {
    final UserPrefs value = UserPrefs(
      expecting: expecting.value,
      faiths: {...faiths},
      languages: {...languages},
    );
    if (editing) {
      await _prefs.save(value);
      Get.back<void>();
      return;
    }
    await _prefs.completeOnboarding(value);
    if (Get.isRegistered<NotificationsService>()) {
      unawaited(Get.find<NotificationsService>().requestAndSubscribe());
    }
    await Get.offAllNamed<void>(Routes.shell);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
