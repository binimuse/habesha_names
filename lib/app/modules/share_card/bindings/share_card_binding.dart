import 'package:get/get.dart';

import '../../../data/models/name_model.dart';
import '../../../services/purchase_service.dart';
import '../controllers/share_card_controller.dart';

/// Route arguments: the [NameModel] to put on the card.
class ShareCardBinding extends Bindings {
  @override
  void dependencies() {
    final NameModel name = Get.arguments as NameModel;
    Get.lazyPut<ShareCardController>(
      () => ShareCardController(name, Get.find<PurchaseService>()),
    );
  }
}
