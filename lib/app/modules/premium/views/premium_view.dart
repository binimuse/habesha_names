import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_logo.dart';
import '../../../widgets/tilet_band.dart';
import '../controllers/premium_controller.dart';

class PremiumView extends GetView<PremiumController> {
  const PremiumView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final List<(IconData, String)> perks = [
      (Icons.block_rounded, LocaleKeys.premiumNoAds.tr),
      (Icons.style_rounded, LocaleKeys.premiumTemplates.tr),
      (Icons.offline_bolt_rounded, LocaleKeys.premiumOfflineAudio.tr),
    ];
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          0,
          AppSpacing.page,
          AppSpacing.xxxl,
        ),
        children: [
          const Center(child: AppLogo(size: 88)).animate().scale(
            curve: AppCurves.emphasized,
            duration: AppDurations.slow,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            LocaleKeys.premiumTitle.tr,
            textAlign: TextAlign.center,
            style: text.displaySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            LocaleKeys.premiumSubtitle.tr,
            textAlign: TextAlign.center,
            style: text.bodyMedium!.copyWith(color: context.palette.inkMuted),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                const TiletBand(height: 14),
                for (final (IconData icon, String label) in perks)
                  ListTile(
                    leading: Icon(icon, color: context.palette.gold),
                    title: Text(label),
                    trailing: Icon(
                      Icons.check_rounded,
                      color: context.palette.unisex,
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Obx(() {
            if (controller.isPremium) {
              return Text(
                LocaleKeys.premiumActive.tr,
                textAlign: TextAlign.center,
                style: text.titleMedium!.copyWith(
                  color: context.palette.unisex,
                ),
              );
            }
            final String? price = controller.price;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  onPressed: controller.pending ? null : controller.buy,
                  child: controller.pending
                      ? Text(LocaleKeys.premiumPending.tr)
                      : Text(
                          price == null
                              ? LocaleKeys.premiumBuyNoPrice.tr
                              : LocaleKeys.premiumBuy.trParams({
                                  'price': price,
                                }),
                        ),
                ),
                if (controller.failed) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    LocaleKeys.premiumError.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.colors.error),
                  ),
                ],
              ],
            );
          }),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: controller.restore,
            child: Text(LocaleKeys.premiumRestore.tr),
          ),
        ],
      ),
    );
  }
}
