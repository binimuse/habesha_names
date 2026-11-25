import 'package:get/get.dart';

import '../../../services/partner_service.dart';
import '../controllers/partner_controller.dart';

class PartnerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnerController>(
      () => PartnerController(Get.find<PartnerService>()),
    );
  }
}
