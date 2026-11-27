import 'package:get/get.dart';

import '../../../services/partner_service.dart';
import '../../discover/bindings/discover_binding.dart';
import '../../favorites/bindings/favorites_binding.dart';
import '../../search/bindings/search_binding.dart';
import '../../studio/bindings/studio_binding.dart';
import '../../swipe/bindings/swipe_binding.dart';
import '../controllers/shell_controller.dart';

/// The shell hosts all five tabs, so it registers their dependencies too.
class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShellController>(
      () => ShellController(Get.find<PartnerService>()),
    );
    DiscoverBinding().dependencies();
    SearchBinding().dependencies();
    SwipeBinding().dependencies();
    FavoritesBinding().dependencies();
    StudioBinding().dependencies();
  }
}
