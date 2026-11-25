import 'package:get/get.dart';

import '../../../data/repositories/names_repository.dart';
import '../../../services/ai_waitlist_service.dart';
import '../../../services/preferences_service.dart';
import '../controllers/ai_waitlist_controller.dart';
import '../controllers/discover_controller.dart';

class DiscoverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiscoverController>(
      () => DiscoverController(
        Get.find<NamesRepository>(),
        Get.find<PreferencesService>(),
      ),
    );
    Get.lazyPut<AiWaitlistController>(
      () => AiWaitlistController(Get.find<AiWaitlistService>()),
    );
  }
}
