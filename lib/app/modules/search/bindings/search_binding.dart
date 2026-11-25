import 'package:get/get.dart';

import '../../../data/repositories/names_repository.dart';
import '../controllers/search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NameSearchController>(
      () => NameSearchController(Get.find<NamesRepository>()),
    );
  }
}
