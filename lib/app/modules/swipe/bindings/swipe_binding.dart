import 'package:get/get.dart';

import '../../../data/providers/seen_names_store.dart';
import '../../../data/repositories/names_repository.dart';
import '../../../services/favorites_service.dart';
import '../../../services/partner_service.dart';
import '../../../services/preferences_service.dart';
import '../../../services/storage_service.dart';
import '../controllers/swipe_controller.dart';

class SwipeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SwipeController>(
      () => SwipeController(
        Get.find<NamesRepository>(),
        Get.find<PreferencesService>(),
        Get.find<FavoritesService>(),
        StorageSeenNamesStore(Get.find<StorageService>()),
        Get.find<PartnerService>(),
      ),
    );
  }
}
