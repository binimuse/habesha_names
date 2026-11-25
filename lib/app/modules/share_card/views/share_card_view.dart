import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../controllers/share_card_controller.dart';
import '../widgets/share_card_art.dart';

class ShareCardView extends GetView<ShareCardController> {
  const ShareCardView({super.key});

  static String label(ShareCardTemplate t) => switch (t) {
    ShareCardTemplate.classic => LocaleKeys.shareCardClassic.tr,
    ShareCardTemplate.tilet => LocaleKeys.shareCardTilet.tr,
    ShareCardTemplate.night => LocaleKeys.shareCardNight.tr,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.shareCardTitle.tr)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          Obx(
            () => ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: context.palette.cardShadow,
                ),
                child: RepaintBoundary(
                  key: controller.cardKey,
                  child: ShareCardArt(
                    name: controller.name,
                    template: controller.template.value,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Obx(
            () => Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: [
                for (final ShareCardTemplate t in ShareCardTemplate.values)
                  ChoiceChip(
                    label: Text(label(t)),
                    avatar: controller.isLocked(t)
                        ? Icon(
                            Icons.lock_rounded,
                            size: 16,
                            color: context.palette.gold,
                          )
                        : null,
                    tooltip: controller.isLocked(t)
                        ? LocaleKeys.shareCardLocked.tr
                        : null,
                    selected: controller.template.value == t,
                    onSelected: (_) => controller.select(t),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Obx(
            () => FilledButton.icon(
              onPressed: controller.exporting.value ? null : controller.share,
              icon: controller.exporting.value
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.ios_share_rounded),
              label: Text(LocaleKeys.detailShare.tr),
            ),
          ),
        ],
      ),
    );
  }
}
