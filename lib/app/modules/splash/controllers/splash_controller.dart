import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../data/repositories/names_repository.dart';
import '../../../routes/app_pages.dart';
import '../../../services/preferences_service.dart';

class SplashController extends GetxController {
  SplashController(this._names, this._prefs);

  /// Long enough to enjoy the animation, short enough not to annoy.
  static const Duration _minDuration = Duration(milliseconds: 1600);

  final NamesRepository _names;
  final PreferencesService _prefs;

  final RxBool hasError = false.obs;

  @override
  void onReady() {
    super.onReady();
    start();
  }

  Future<void> start() async {
    hasError.value = false;
    try {
      await Future.wait([
        _names.ensureReady(), // seeds the DB on first launch
        Future<void>.delayed(_minDuration),
      ]);
      await Get.offAllNamed<void>(
        _prefs.onboardingDone.value ? Routes.shell : Routes.onboarding,
      );
    } catch (error) {
      debugPrint('Splash failed: $error');
      hasError.value = true;
    }
  }
}
