import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../data/models/ai_feature.dart';
import '../../../services/ai_waitlist_service.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../controllers/ai_waitlist_controller.dart';

/// Waitlist form, or "You're on the list" once joined.
class AiWaitlistSheet extends GetView<AiWaitlistController> {
  const AiWaitlistSheet({super.key});

  static Future<void> show(BuildContext context) {
    Get.find<AiWaitlistController>().open();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AiWaitlistSheet(),
    );
  }

  static String featureLabel(AiFeature f) => switch (f) {
    AiFeature.nameFinder => LocaleKeys.aiFeatureNameFinder.tr,
    AiFeature.facePreview => LocaleKeys.aiFeatureFacePreview.tr,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Obx(
          () => AnimatedSwitcher(
            duration: AppDurations.medium,
            child: controller.joined
                ? _OnList(
                    key: const ValueKey('on-list'),
                    justJoined: controller.justJoined.value,
                  )
                : const _Form(key: ValueKey('form')),
          ),
        ),
      ),
    );
  }
}

class _Form extends GetView<AiWaitlistController> {
  const _Form({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(LocaleKeys.aiSheetTitle.tr, style: text.headlineSmall),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: controller.text,
          minLines: 3,
          maxLines: 5,
          maxLength: AiWaitlistService.maxTextLength,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: LocaleKeys.aiSheetHint.tr),
        ),
        Obx(
          () => Column(
            children: [
              for (final AiFeature f in AiFeature.values)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: context.palette.gold,
                  value: controller.chosen.contains(f),
                  onChanged: (_) => controller.toggle(f),
                  title: Text(AiWaitlistSheet.featureLabel(f)),
                ),
            ],
          ),
        ),
        Obx(
          () => controller.errorKey.value == null
              ? const SizedBox(height: AppSpacing.sm)
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    controller.errorKey.value!.tr,
                    style: text.bodyMedium!.copyWith(
                      color: context.colors.error,
                    ),
                  ),
                ),
        ),
        Obx(
          () => FilledButton.icon(
            onPressed: controller.canSubmit ? controller.submit : null,
            icon: controller.busy
                ? SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colors.onPrimary,
                    ),
                  )
                : const Icon(Icons.notifications_active_rounded),
            label: Text(LocaleKeys.aiNotifyMe.tr),
          ),
        ),
      ],
    );
  }
}

class _OnList extends GetView<AiWaitlistController> {
  const _OnList({super.key, required this.justJoined});

  final bool justJoined;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color gold = context.palette.gold;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          justJoined ? Icons.celebration_rounded : Icons.check_circle_rounded,
          size: 56,
          color: gold,
        ).animate().scale(
          begin: const Offset(0.6, 0.6),
          curve: AppCurves.emphasized,
          duration: AppDurations.slow,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          justJoined
              ? LocaleKeys.aiThanksTitle.tr
              : LocaleKeys.aiOnListTitle.tr,
          textAlign: TextAlign.center,
          style: text.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          justJoined
              ? LocaleKeys.aiThanksMessage.tr
              : LocaleKeys.aiOnListMessage.tr,
          textAlign: TextAlign.center,
          style: text.bodyMedium!.copyWith(color: context.palette.inkMuted),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
          children: [
            for (final AiFeature f in controller.joinedFeatures)
              Chip(
                avatar: Icon(Icons.check_rounded, size: 16, color: gold),
                label: Text(AiWaitlistSheet.featureLabel(f)),
                backgroundColor: context.palette.goldSoft,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: Text(LocaleKeys.aiClose.tr),
        ),
      ],
    );
  }
}
