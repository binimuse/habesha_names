import 'package:get/get.dart';

import '../../../data/models/name_model.dart';
import '../../../data/repositories/names_repository.dart';
import '../../../services/storage_service.dart';
import '../controllers/full_name_controller.dart';

/// Route arguments: the [NameModel] to use as the given name.
class FullNameBinding extends Bindings {
  @override
  void dependencies() {
    final NameModel name = Get.arguments as NameModel;
    Get.lazyPut<FullNameController>(
      () => FullNameController(
        name,
        Get.find<NamesRepository>(),
        Get.find<StorageService>(),
      ),
    );
  }
}
