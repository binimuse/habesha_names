import 'package:get/get.dart';

import '../../../data/models/name_model.dart';
import '../controllers/reveal_video_controller.dart';

/// Route arguments: the [NameModel] to reveal.
class RevealVideoBinding extends Bindings {
  @override
  void dependencies() {
    final NameModel name = Get.arguments as NameModel;
    Get.lazyPut<RevealVideoController>(() => RevealVideoController(name));
  }
}
