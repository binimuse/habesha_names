import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../controllers/reels_controller.dart';

/// Modern · Rare · Boy · Girl, floating over the feed.
class ReelChips extends GetView<ReelsController> {
  const ReelChips({super.key});

  static String label(ReelsChip c) => switch (c) {
    ReelsChip.modern => LocaleKeys.reelsModern.tr,
    ReelsChip.rare => LocaleKeys.rarityRare.tr,
    ReelsChip.boy => LocaleKeys.genderBoy.tr,
    ReelsChip.girl => LocaleKeys.genderGirl.tr,
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 52,
        child: Obx(
          () => ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.page,
              vertical: AppSpacing.sm,
            ),
            children: [
              for (final ReelsChip c in ReelsChip.values) ...[
                FilterChip(
                  label: Text(label(c)),
                  selected: controller.chips.contains(c),
                  showCheckmark: false,
                  backgroundColor: context.colors.surface.withValues(
                    alpha: 0.75,
                  ),
                  selectedColor: context.palette.gold.withValues(alpha: 0.35),
                  onSelected: (_) => controller.toggleChip(c),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
