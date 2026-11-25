import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_x.dart';
import '../../../core/utils/labels.dart';
import '../../../data/models/name_model.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/name_title.dart';
import '../../../widgets/pill.dart';
import '../../../widgets/state/empty_view.dart';
import '../../../widgets/state/loading_view.dart';
import '../../../widgets/tilet_band.dart';
import '../controllers/match_controller.dart';

class MatchView extends GetView<MatchController> {
  const MatchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.palette.girlSoft,
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: controller.obx(
            (name) => _Content(name: name!),
            onLoading: const LoadingView(),
            onEmpty: EmptyView(
              icon: Icons.favorite_border_rounded,
              title: LocaleKeys.detailNotFound.tr,
              action: TextButton(
                onPressed: controller.keepSwiping,
                child: Text(LocaleKeys.matchKeepSwiping.tr),
              ),
            ),
            onError: (_) => EmptyView(
              icon: Icons.favorite_border_rounded,
              title: LocaleKeys.detailNotFound.tr,
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends GetView<MatchController> {
  const _Content({required this.name});

  final NameModel name;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      children: [
        const TiletBand(height: 22),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Column(
              children: [
                SizedBox(
                  height: 260,
                  child: Lottie.asset(AppAssets.matchLottie, repeat: false),
                ),
                Text(
                  LocaleKeys.matchTitle.tr,
                  textAlign: TextAlign.center,
                  style: text.displayMedium!.copyWith(
                    color: context.colors.primary,
                  ),
                ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.3, end: 0),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  LocaleKeys.matchMessage.tr,
                  style: text.bodyLarge!.copyWith(
                    color: context.palette.inkMuted,
                  ),
                ).animate(delay: 400.ms).fadeIn(),
                const SizedBox(height: AppSpacing.xl),
                Hero(
                      tag: MatchController.heroTag,
                      child: NameTitle(
                        name: name,
                        height: 120,
                        alignment: Alignment.center,
                      ),
                    )
                    .animate(delay: 550.ms)
                    .fadeIn()
                    .scale(
                      begin: const Offset(0.85, 0.85),
                      curve: AppCurves.emphasized,
                    ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  Labels.meaning(name),
                  textAlign: TextAlign.center,
                  style: text.titleMedium,
                ),
                if (controller.match?.superLike ?? false) ...[
                  const SizedBox(height: AppSpacing.md),
                  Pill(
                    icon: Icons.star_rounded,
                    label: LocaleKeys.matchSuper.tr,
                    color: context.palette.gold,
                    background: context.palette.goldSoft,
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                onPressed: controller.viewName,
                child: Text(LocaleKeys.matchView.tr),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: controller.keepSwiping,
                child: Text(LocaleKeys.matchKeepSwiping.tr),
              ),
            ],
          ),
        ).animate(delay: 700.ms).fadeIn(),
      ],
    );
  }
}
