import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../data/models/name_model.dart';
import '../../../theme/app_dimens.dart';
import '../../../services/ads_service.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/ad_slots.dart';
import '../../../widgets/name_card.dart';
import '../../../widgets/page_header.dart';
import '../../../widgets/state/empty_view.dart';
import '../../../widgets/state/error_view.dart';
import '../../../widgets/state/loading_view.dart';
import '../controllers/search_controller.dart';
import '../widgets/letter_index.dart';
import '../widgets/search_field.dart';

class SearchView extends GetView<NameSearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(title: LocaleKeys.searchTitle.tr),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: SearchField(),
          ),
          const SizedBox(height: AppSpacing.md),
          const LetterIndex(),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: controller.obx(
              (names) => _Results(names: names ?? const []),
              onLoading: const LoadingView(),
              onEmpty: const _SearchEmpty(),
              onError: (_) => ErrorView(onRetry: controller.load),
            ),
          ),
        ],
      ),
    );
  }
}

class _Results extends GetView<NameSearchController> {
  const _Results({required this.names});

  final List<NameModel> names;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.xxxl,
      ),
      itemCount: AdInterleave.itemCount(names.length) + 1,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Text(
            LocaleKeys.searchResultsCount.trParams({
              'count': '${names.length}',
            }),
            style: Theme.of(
              context,
            ).textTheme.labelLarge!.copyWith(color: context.palette.inkMuted),
          );
        }
        // A native ad after every 12 results (hidden for Premium).
        if (AdInterleave.isAd(i - 1)) return const NativeAdSlot();
        final NameModel n = names[AdInterleave.itemIndex(i - 1)];
        final String tag = nameHeroTag('search', n.id);
        return NameCard(
              name: n,
              heroTag: tag,
              onTap: () => controller.openName(n, tag),
            )
            .animate(delay: (30 * (i.clamp(0, 10))).ms)
            .fadeIn(duration: AppDurations.medium)
            .slideY(begin: 0.06, end: 0, curve: AppCurves.standard);
      },
    );
  }
}

/// Idle (browse prompt) vs. "no results" for the current query / filters.
class _SearchEmpty extends GetView<NameSearchController> {
  const _SearchEmpty();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isIdle) {
        return EmptyView(
          icon: Icons.manage_search_rounded,
          title: LocaleKeys.searchIdleTitle.tr,
          message: LocaleKeys.searchIdleMessage.tr,
        );
      }
      return EmptyView(
        icon: Icons.search_off_rounded,
        title: LocaleKeys.searchNoResultsTitle.tr,
        message: LocaleKeys.searchNoResultsMessage.tr,
        action: controller.filter.value.isEmpty
            ? null
            : OutlinedButton(
                onPressed: controller.clearFilters,
                child: Text(LocaleKeys.searchClearFilters.tr),
              ),
      );
    });
  }
}
