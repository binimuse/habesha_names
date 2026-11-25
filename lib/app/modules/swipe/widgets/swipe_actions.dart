import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../controllers/swipe_controller.dart';

/// Skip · Undo · Super like · Like.
class SwipeActions extends GetView<SwipeController> {
  const SwipeActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool hasCard = controller.current != null;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _RoundButton(
            tooltip: LocaleKeys.swipeSkip.tr,
            icon: Icons.close_rounded,
            size: 60,
            color: context.palette.inkMuted,
            onPressed: hasCard
                ? () => controller.swipe(SwipeChoice.skip)
                : null,
          ),
          const SizedBox(width: AppSpacing.lg),
          _RoundButton(
            tooltip: LocaleKeys.swipeUndo.tr,
            icon: Icons.undo_rounded,
            size: 46,
            color: context.palette.boy,
            onPressed: controller.canUndo.value ? controller.undo : null,
          ),
          const SizedBox(width: AppSpacing.lg),
          _RoundButton(
            tooltip: LocaleKeys.swipeSuperLike.tr,
            icon: Icons.star_rounded,
            size: 46,
            color: context.palette.gold,
            onPressed: hasCard
                ? () => controller.swipe(SwipeChoice.superLike)
                : null,
          ),
          const SizedBox(width: AppSpacing.lg),
          _RoundButton(
            tooltip: LocaleKeys.swipeLike.tr,
            icon: Icons.favorite_rounded,
            size: 60,
            color: context.palette.girl,
            onPressed: hasCard
                ? () => controller.swipe(SwipeChoice.like)
                : null,
          ),
        ],
      );
    });
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.tooltip,
    required this.icon,
    required this.size,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool on = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: AnimatedOpacity(
        opacity: on ? 1 : 0.4,
        duration: AppDurations.fast,
        child: Material(
          color: context.colors.surface,
          shape: const CircleBorder(),
          elevation: on ? 3 : 0,
          shadowColor: color.withValues(alpha: 0.45),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox.square(
              dimension: size,
              child: Icon(icon, color: color, size: size * 0.46),
            ),
          ),
        ),
      ),
    );
  }
}
