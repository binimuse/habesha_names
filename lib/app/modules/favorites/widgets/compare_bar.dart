import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../controllers/favorites_controller.dart';

/// Floating bar: "Compare" → select two → "Compare" again to open.
class CompareBar extends GetView<FavoritesController> {
  const CompareBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.selecting.value) {
        return Align(
          alignment: Alignment.centerRight,
          child: FloatingActionButton.extended(
            heroTag: null,
            onPressed: controller.startCompare,
            icon: const Icon(Icons.compare_arrows_rounded),
            label: Text(LocaleKeys.favoritesCompare.tr),
          ),
        );
      }
      return Material(
        elevation: 6,
        color: context.colors.inverseSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  controller.selected.isEmpty
                      ? LocaleKeys.favoritesCompareHint.tr
                      : LocaleKeys.favoritesCompareSelected.trParams({
                          'count': '${controller.selected.length}',
                        }),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: context.colors.onInverseSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: controller.cancelCompare,
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.onInverseSurface,
                ),
                child: Text(LocaleKeys.favoritesCancel.tr),
              ),
              FilledButton(
                onPressed: controller.canCompare ? controller.compare : null,
                child: Text(LocaleKeys.favoritesCompare.tr),
              ),
            ],
          ),
        ),
      );
    });
  }
}
