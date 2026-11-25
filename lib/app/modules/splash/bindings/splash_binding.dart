import 'package:get/get.dart';

import '../../../data/repositories/names_repository.dart';
import '../../../services/preferences_service.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(
        Get.find<NamesRepository>(),
        Get.find<PreferencesService>(),
      ),
    );
  }
}
