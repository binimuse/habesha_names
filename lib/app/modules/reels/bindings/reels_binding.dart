import 'package:get/get.dart';

import '../../../data/repositories/names_repository.dart';
import '../controllers/reels_controller.dart';

class ReelsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReelsController>(
      () => ReelsController(Get.find<NamesRepository>()),
    );
  }
}
