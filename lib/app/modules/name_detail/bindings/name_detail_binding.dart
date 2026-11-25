import 'package:get/get.dart';

import '../../../data/repositories/names_repository.dart';
import '../../../routes/app_nav.dart';
import '../../../services/audio_service.dart';
import '../controllers/name_detail_controller.dart';

class NameDetailBinding extends Bindings {
  @override
  void dependencies() {
    final NameDetailArgs args = NameDetailArgs.current();
    Get.lazyPut<NameDetailController>(
      () => NameDetailController(
        args,
        Get.find<NamesRepository>(),
        Get.find<AudioService>(),
      ),
      tag: args.tag,
    );
  }
}
