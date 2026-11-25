import 'package:get/get.dart';

import '../../../data/repositories/names_repository.dart';
import '../../../services/partner_service.dart';
import '../controllers/matches_controller.dart';

class MatchesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MatchesController>(
      () => MatchesController(
        Get.find<PartnerService>(),
        Get.find<NamesRepository>(),
      ),
    );
  }
}
