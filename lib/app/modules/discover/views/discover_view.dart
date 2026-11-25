import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/utils/labels.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/page_header.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/state/empty_view.dart';
import '../../../widgets/state/error_view.dart';
import '../../../widgets/state/loading_view.dart';
import '../controllers/discover_controller.dart';
import '../../../widgets/name_carousel.dart';
import '../widgets/ai_teaser_card.dart';
import '../widgets/name_of_day_card.dart';

class DiscoverView extends GetView<DiscoverController> {
  const DiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: controller.obx(
        (data) => _Content(data: data!),
        onLoading: const LoadingView(),
        onEmpty: EmptyView(
          icon: Icons.auto_awesome_rounded,
          accent: context.palette.gold,
          title: LocaleKeys.discoverEmptyTitle.tr,
          message: LocaleKeys.discoverEmptyMessage.tr,
        ),
        onError: (_) => ErrorView(onRetry: controller.load),
      ),
    );
  }
}

class _Content extends GetView<DiscoverController> {
  const _Content({required this.data});

  final DiscoverData data;

  @override
  Widget build(BuildContext context) {
    final List<Widget> sections = [
      PageHeader(
        title: LocaleKeys.discoverTitle.tr,
        subtitle: LocaleKeys.discoverSubtitle.tr,
        useDisplayFont: true,
      ),
      if (data.nameOfDay != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: NameOfDayCard(
            name: data.nameOfDay!,
            onTap: controller.openName,
          ),
        ),
      const Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.lg,
          AppSpacing.page,
          0,
        ),
        child: AiTeaserCard(),
      ),
      if (data.forYou.isNotEmpty) ...[
        SectionHeader(
          title: LocaleKeys.discoverForYou.tr,
          subtitle: LocaleKeys.discoverForYouHint.tr,
          actionLabel: LocaleKeys.discoverSeeAll.tr,
          onAction: controller.seeAllForYou,
        ),
        NameCarousel(
          section: 'for-you',
          names: data.forYou,
          onTap: controller.openName,
        ),
      ],
      if (data.trending.isNotEmpty) ...[
        SectionHeader(title: LocaleKeys.discoverTrending.tr),
        NameCarousel(
          section: 'trending',
          names: data.trending,
          onTap: controller.openName,
        ),
      ],
      for (final group in data.themes) ...[
        SectionHeader(
          title: Labels.theme(group.theme),
          actionLabel: LocaleKeys.discoverSeeAll.tr,
          onAction: () => controller.seeTheme(group.theme),
        ),
        NameCarousel(
          section: 'theme-${group.theme}',
          names: group.names,
          onTap: controller.openName,
        ),
      ],
      const SizedBox(height: AppSpacing.xxxl),
    ];

    return ListView(
      padding: EdgeInsets.zero,
      children: sections
          .animate(interval: 50.ms)
          .fadeIn(duration: AppDurations.medium)
          .slideY(begin: 0.04, end: 0, curve: AppCurves.standard),
    );
  }
}
