import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/utils/labels.dart';
import '../../../data/models/gender.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/gender_style.dart';
import '../../../translations/locale_keys.dart';
import '../controllers/swipe_controller.dart';

/// Chips above the deck: gender and "easy abroad".
class QuickFilters extends GetView<SwipeController> {
  const QuickFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Obx(
        () => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          children: [
            for (final Gender g in Gender.values) ...[
              _chip(
                context,
                label: Labels.gender(g),
                icon: g.icon,
                color: g.color(context.palette),
                selected: controller.genders.contains(g),
                onTap: () => controller.toggleGender(g),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            _chip(
              context,
              label: LocaleKeys.filterEasyAbroad.tr,
              icon: Icons.flight_takeoff_rounded,
              color: context.palette.gold,
              selected: controller.easyAbroad.value,
              onTap: controller.toggleEasyAbroad,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: color.withValues(alpha: 0.22),
      side: BorderSide(color: selected ? color : Colors.transparent),
      onSelected: (_) => onTap(),
    );
  }
}
