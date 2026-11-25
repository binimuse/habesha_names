import 'package:get/get.dart';

import '../../../data/models/couple.dart';
import '../../../data/repositories/names_repository.dart';
import '../../../services/partner_service.dart';
import '../controllers/match_controller.dart';

class MatchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MatchController>(
      () => MatchController(
        Get.arguments is NameMatch ? Get.arguments as NameMatch : null,
        Get.find<NamesRepository>(),
        Get.find<PartnerService>(),
      ),
    );
  }
}
