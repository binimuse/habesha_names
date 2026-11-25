import 'package:get/get.dart';

import '../../../services/preferences_service.dart';
import '../../../services/settings_service.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(
        Get.find<SettingsService>(),
        Get.find<PreferencesService>(),
      ),
    );
  }
}
