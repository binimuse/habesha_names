import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/utils/labels.dart';
import '../../../data/models/name_model.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/gender_style.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/favorite_button.dart';
import '../../../widgets/name_title.dart';
import '../../../widgets/pill.dart';
import '../../../widgets/rarity_pill.dart';
import '../controllers/reels_controller.dart';

/// One full-screen name.
class ReelPage extends GetView<ReelsController> {
  const ReelPage({super.key, required this.name});

  final NameModel name;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color tint = name.gender.color(context.palette);
    return GestureDetector(
      onTap: () => controller.open(name),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              name.gender.soft(context.palette),
              Theme.of(context).scaffoldBackgroundColor,
              tint.withValues(alpha: 0.18),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  72,
                  88,
                  AppSpacing.xxl,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RarityPill(rarity: name.rarity),
                    const SizedBox(height: AppSpacing.xl),
                    Hero(
                      tag: ReelsController.heroTagFor(name),
                      child: NameTitle(name: name, height: 200),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(Labels.meaning(name), style: text.headlineSmall),
                    if (Labels.secondaryMeaning(name).isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        Labels.secondaryMeaning(name),
                        style: text.bodyLarge!.copyWith(
                          color: context.palette.inkMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    GenderPill(gender: name.gender),
                  ],
                ).animate().fadeIn(duration: AppDurations.medium),
              ),
              Positioned(
                right: AppSpacing.md,
                bottom: AppSpacing.xxl,
                child: _Actions(name: name),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Actions extends GetView<ReelsController> {
  const _Actions({required this.name});

  final NameModel name;

  @override
  Widget build(BuildContext context) {
    Widget round(Widget child) => Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.85),
        shape: BoxShape.circle,
        boxShadow: context.palette.cardShadow,
      ),
      child: child,
    );
    return Column(
      children: [
        round(FavoriteButton(nameId: name.id, size: 28)),
        round(
          IconButton(
            tooltip: LocaleKeys.detailShare.tr,
            onPressed: () => controller.share(name),
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ),
        if (name.audioUrl != null)
          round(
            Obx(
              () => IconButton(
                tooltip: controller.muted.value
                    ? LocaleKeys.reelsUnmute.tr
                    : LocaleKeys.reelsMute.tr,
                onPressed: controller.toggleMute,
                icon: Icon(
                  controller.muted.value
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
