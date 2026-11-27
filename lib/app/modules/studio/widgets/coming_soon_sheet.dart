import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../data/models/ai_feature.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../../discover/widgets/ai_waitlist_sheet.dart';
import '../controllers/studio_controller.dart';

/// "Feature X is coming soon" — offers the waitlist (or confirms you're on
/// it) instead of running the AI tool.
class ComingSoonSheet extends GetView<StudioController> {
  const ComingSoonSheet({super.key});

  static Future<void> show(BuildContext context, AiFeature feature) {
    Get.find<StudioController>().prepareComingSoon(feature);
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (_) => const ComingSoonSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final AiFeature feature = controller.soonFeature.value;
    final bool onList = controller.onWaitlist;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [context.colors.primary, context.palette.gold],
                  ),
                ),
                child: Icon(
                  feature == AiFeature.nameFinder
                      ? Icons.auto_awesome_rounded
                      : Icons.face_retouching_natural_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 0.94, end: 1.04, duration: 1200.ms),
          const SizedBox(height: AppSpacing.lg),
          Text(
            LocaleKeys.studioSoonTitle.trParams({
              'feature': AiWaitlistSheet.featureLabel(feature),
            }),
            textAlign: TextAlign.center,
            style: text.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            onList
                ? LocaleKeys.studioSoonJoined.tr
                : LocaleKeys.studioSoonMessage.tr,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: context.palette.inkMuted),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: onList
                ? OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: Text(LocaleKeys.aiClose.tr),
                  )
                : FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      AiWaitlistSheet.show(context);
                    },
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: Text(LocaleKeys.aiNotifyMe.tr),
                  ),
          ),
        ],
      ),
    );
  }
}
