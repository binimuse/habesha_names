import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../data/models/name_model.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/page_header.dart';
import '../../../widgets/state/empty_view.dart';
import '../../../widgets/state/error_view.dart';
import '../../../widgets/state/loading_view.dart';
import '../controllers/swipe_controller.dart';
import '../widgets/heart_burst.dart';
import '../widgets/quick_filters.dart';
import '../widgets/swipe_actions.dart';
import '../widgets/swipe_card.dart';
import '../widgets/swipe_stamp.dart';

class SwipeView extends GetView<SwipeController> {
  const SwipeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: LocaleKeys.swipeTitle.tr,
            subtitle: LocaleKeys.swipeSubtitle.tr,
            actions: const [_PartnerButton()],
          ),
          const QuickFilters(),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: controller.obx(
              (names) => _Deck(names: names ?? const []),
              onLoading: const LoadingView(),
              onEmpty: const _Empty(),
              onError: (_) => ErrorView(onRetry: controller.load),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnerButton extends GetView<SwipeController> {
  const _PartnerButton();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final int unseen = controller.unseenMatches;
      return IconButton(
        tooltip: LocaleKeys.partnerTitle.tr,
        onPressed: controller.openPartner,
        icon: Badge(
          isLabelVisible: unseen > 0,
          label: Text('$unseen'),
          backgroundColor: context.colors.primary,
          child: Icon(
            controller.partnerLinked
                ? Icons.people_alt_rounded
                : Icons.people_alt_outlined,
          ),
        ),
      );
    });
  }
}

class _Deck extends GetView<SwipeController> {
  const _Deck({required this.names});

  final List<NameModel> names;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        children: [
          Obx(
            () => Text(
              LocaleKeys.swipeRemaining.trParams({
                'count': '${controller.remaining}',
              }),
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: context.palette.inkMuted,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                CardSwiper(
                  // New deck (filters / start over) → fresh swiper state.
                  key: ValueKey(Object.hashAll(names.map((n) => n.id))),
                  controller: controller.swiper,
                  cardsCount: names.length,
                  numberOfCardsDisplayed: math.min(3, names.length),
                  allowedSwipeDirection: const AllowedSwipeDirection.only(
                    left: true,
                    right: true,
                    up: true,
                  ),
                  isLoop: false,
                  maxAngle: 22,
                  threshold: 45,
                  scale: 0.92,
                  backCardOffset: const Offset(0, 26),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                    vertical: AppSpacing.lg,
                  ),
                  onSwipe: controller.onSwipe,
                  onUndo: controller.onUndo,
                  onEnd: controller.onEnd,
                  cardBuilder: (context, i, dx, dy) => GestureDetector(
                    onTap: controller.openCurrent,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        SwipeCard(
                          name: names[i],
                          heroTag: SwipeController.heroTagFor(names[i]),
                        ),
                        SwipeStamp(dx: dx, dy: dy),
                      ],
                    ),
                  ),
                ),
                Obx(() {
                  final int n = controller.burst.value;
                  if (n == 0) return const SizedBox.shrink();
                  return HeartBurst(
                    key: ValueKey('burst-$n'),
                    superLike:
                        controller.burstKind.value == SwipeChoice.superLike,
                  );
                }),
                Obx(
                  () => controller.finished.value
                      ? const Positioned.fill(child: _Done())
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SwipeActions(),
        ],
      ),
    );
  }
}

/// Shown over the (empty) swiper after the last card.
class _Done extends GetView<SwipeController> {
  const _Done();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: EmptyView(
        icon: Icons.celebration_rounded,
        accent: context.palette.gold,
        title: LocaleKeys.swipeDoneTitle.tr,
        message: LocaleKeys.swipeDoneMessage.tr,
        action: FilledButton.icon(
          onPressed: controller.startOver,
          icon: const Icon(Icons.replay_rounded),
          label: Text(LocaleKeys.swipeStartOver.tr),
        ),
      ),
    );
  }
}

/// Nothing to show: everything seen (offer Start over) or no names match.
class _Empty extends GetView<SwipeController> {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    if (controller.hasSeenAll) return const _Done();
    return EmptyView(
      icon: Icons.style_rounded,
      accent: context.palette.boy,
      title: LocaleKeys.swipeEmptyTitle.tr,
      message: LocaleKeys.swipeEmptyMessage.tr,
    );
  }
}
