import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../data/models/name_model.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/gender_style.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/name_title.dart';
import '../../../widgets/pill.dart';
import '../../../widgets/tilet_band.dart';
import '../controllers/name_detail_controller.dart';

/// Gender-tinted header: tilet band, big Hero title, pronunciation, pills.
class DetailHeader extends StatelessWidget {
  const DetailHeader({super.key, required this.controller, required this.name});

  final NameDetailController controller;
  final NameModel name;

  @override
  Widget build(BuildContext context) {
    final double top = MediaQuery.paddingOf(context).top + kToolbarHeight;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            name.gender.soft(context.palette),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      padding: EdgeInsets.only(top: top),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TiletBand(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.xl,
              AppSpacing.page,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: controller.heroTag,
                  child: NameTitle(name: name, height: 132),
                ),
                const SizedBox(height: AppSpacing.lg),
                _Pronunciation(controller: controller, name: name),
                const SizedBox(height: AppSpacing.md),
                // One scrollable row so small screens keep the meaning in view.
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: OutlinedButtonTheme(
                    data: OutlinedButtonThemeData(
                      style: Theme.of(context).outlinedButtonTheme.style!
                          .copyWith(
                            minimumSize: const WidgetStatePropertyAll(
                              Size(0, 40),
                            ),
                            padding: const WidgetStatePropertyAll(
                              EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            ),
                          ),
                    ),
                    child: Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: controller.openFullName,
                          icon: const Icon(Icons.badge_outlined),
                          label: Text(LocaleKeys.fullNameAction.tr),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        OutlinedButton.icon(
                          onPressed: controller.openShareCard,
                          icon: const Icon(Icons.image_outlined),
                          label: Text(LocaleKeys.shareCardAction.tr),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        OutlinedButton.icon(
                          onPressed: controller.openRevealVideo,
                          icon: const Icon(Icons.movie_outlined),
                          label: Text(LocaleKeys.videoAction.tr),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    GenderPill(gender: name.gender),
                    if (name.syllables > 0)
                      Pill(
                        icon: Icons.graphic_eq_rounded,
                        label: LocaleKeys.detailSyllables.trParams({
                          'count': '${name.syllables}',
                        }),
                      ),
                    if (name.easyAbroad)
                      Pill(
                        icon: Icons.flight_takeoff_rounded,
                        label: LocaleKeys.detailEasyAbroad.tr,
                      ),
                    if (name.verified)
                      Pill(
                        icon: Icons.verified_rounded,
                        label: LocaleKeys.detailVerified.tr,
                        color: context.palette.gold,
                        background: context.palette.goldSoft,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pronunciation extends StatelessWidget {
  const _Pronunciation({required this.controller, required this.name});

  final NameDetailController controller;
  final NameModel name;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool hasAudio = name.audioUrl != null;
    return Row(
      children: [
        Obx(() {
          final bool playing = controller.isPlaying;
          return IconButton.filled(
            tooltip: hasAudio
                ? (playing
                      ? LocaleKeys.detailStop.tr
                      : LocaleKeys.detailPlay.tr)
                : LocaleKeys.detailNoAudio.tr,
            onPressed: hasAudio ? controller.togglePronunciation : null,
            icon: controller.isAudioLoading
                ? SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: context.colors.onPrimary,
                    ),
                  )
                : Icon(playing ? Icons.stop_rounded : Icons.volume_up_rounded),
          );
        }),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.detailPronunciation.tr,
                style: text.labelMedium!.copyWith(
                  color: context.palette.inkMuted,
                ),
              ),
              Text(
                name.pronunciation ??
                    (hasAudio ? '' : LocaleKeys.detailNoAudio.tr),
                style: text.titleMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
