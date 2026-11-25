import 'package:get/get.dart';

import '../../../data/repositories/names_repository.dart';
import '../../../services/favorites_service.dart';
import '../controllers/favorites_controller.dart';

class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoritesController>(
      () => FavoritesController(
        Get.find<FavoritesService>(),
        Get.find<NamesRepository>(),
      ),
    );
  }
}
