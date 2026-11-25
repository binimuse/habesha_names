import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/app_share.dart';
import '../../../core/utils/labels.dart';
import '../../../core/utils/widget_capture.dart';
import '../../../data/models/name_model.dart';
import '../../../routes/app_pages.dart';
import '../../../services/purchase_service.dart';
import '../../../translations/locale_keys.dart';

enum ShareCardTemplate {
  classic(premium: false),
  tilet(premium: true),
  night(premium: true);

  const ShareCardTemplate({required this.premium});

  final bool premium;
}

class ShareCardController extends GetxController {
  ShareCardController(this.name, this._purchases);

  /// 1080 × 1350 (4:5), the best size for Instagram / WhatsApp status.
  static const int exportWidth = 1080;

  final NameModel name;
  final PurchaseService _purchases;

  final GlobalKey cardKey = GlobalKey();
  final Rx<ShareCardTemplate> template = ShareCardTemplate.classic.obs;
  final RxBool exporting = false.obs;

  bool isLocked(ShareCardTemplate t) =>
      t.premium && !_purchases.isPremium.value;

  void select(ShareCardTemplate t) {
    if (isLocked(t)) {
      Get.toNamed<void>(Routes.premium);
      return;
    }
    template.value = t;
  }

  Future<void> share() async {
    if (exporting.value || isLocked(template.value)) return;
    exporting.value = true;
    try {
      final Uint8List png = await WidgetCapture.png(
        cardKey,
        targetWidth: exportWidth,
      );
      final File file = await WidgetCapture.toTempFile(
        png,
        'habesha-${name.id}-${template.value.name}.png',
      );
      await AppShare.share(
        'share_card',
        name.id,
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: LocaleKeys.detailShareText.trParams({
            'latin': name.nameLatin,
            'geez': name.nameGeez,
            'meaning': Labels.meaning(name),
          }),
        ),
      );
    } finally {
      exporting.value = false;
    }
  }
}
