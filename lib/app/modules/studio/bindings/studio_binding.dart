import 'package:get/get.dart';

import '../../../services/ai_waitlist_service.dart';
import '../../discover/controllers/ai_waitlist_controller.dart';
import '../controllers/studio_controller.dart';

class StudioBinding extends Bindings {
  @override
  void dependencies() {
    // Shared with Discover's AI teaser card (same waitlist state).
    if (!Get.isRegistered<AiWaitlistController>()) {
      Get.lazyPut<AiWaitlistController>(
        () => AiWaitlistController(Get.find<AiWaitlistService>()),
      );
    }
    Get.lazyPut<StudioController>(
      () => StudioController(Get.find<AiWaitlistController>()),
    );
  }
}
