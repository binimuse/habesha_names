import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/purchase_service.dart';
import '../../../translations/locale_keys.dart';

class PremiumController extends GetxController {
  PremiumController(this._purchases);

  final PurchaseService _purchases;

  bool get isPremium => _purchases.isPremium.value;
  bool get storeAvailable => _purchases.storeAvailable.value;
  bool get pending => _purchases.pending.value;
  bool get failed => _purchases.lastFailed.value;
  String? get price => _purchases.product.value?.price;

  Future<void> buy() async {
    if (!storeAvailable) return toast(LocaleKeys.premiumUnavailable.tr);
    await _purchases.buy();
  }

  Future<void> restore() async {
    final RestoreResult r = await _purchases.restore();
    toast(switch (r) {
      RestoreResult.restored => LocaleKeys.premiumRestored.tr,
      RestoreResult.nothing => LocaleKeys.premiumNothingToRestore.tr,
      RestoreResult.unavailable => LocaleKeys.premiumUnavailable.tr,
    });
  }

  static void toast(String message) {
    final BuildContext? ctx = Get.context;
    if (ctx == null || !ctx.mounted) return;
    ScaffoldMessenger.of(ctx)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
