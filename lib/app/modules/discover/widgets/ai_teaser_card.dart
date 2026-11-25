import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../controllers/ai_waitlist_controller.dart';
import 'ai_waitlist_sheet.dart';

/// Small gold "Coming soon" card on Discover. Opens [AiWaitlistSheet].
class AiTeaserCard extends GetView<AiWaitlistController> {
  const AiTeaserCard({super.key});

  @override
  Widget build(BuildContext context) {
    final Color gold = context.palette.gold;
    final TextTheme text = Theme.of(context).textTheme;
    final BorderRadius radius = BorderRadius.circular(AppRadius.card);

    final Widget card = Material(
      color: context.palette.goldSoft,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => AiWaitlistSheet.show(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: gold.withValues(alpha: 0.45)),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(LocaleKeys.aiTeaserTitle.tr, style: text.titleSmall),
                    const SizedBox(height: AppSpacing.xxs),
                    Obx(
                      () => Text(
                        controller.joined
                            ? LocaleKeys.aiOnListTitle.tr
                            : LocaleKeys.aiTeaserCta.tr,
                        style: text.bodySmall!.copyWith(
                          color: Color.lerp(
                            gold,
                            context.colors.onSurface,
                            0.35,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => Icon(
                  controller.joined
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                  color: gold,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Subtle shimmer, skipped when the user prefers reduced motion.
    if (MediaQuery.disableAnimationsOf(context)) return card;
    return card
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          delay: const Duration(seconds: 2),
          duration: 1800.ms,
          color: Colors.white.withValues(alpha: 0.35),
        );
  }
}
