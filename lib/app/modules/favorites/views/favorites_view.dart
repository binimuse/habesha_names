import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../routes/app_pages.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/page_header.dart';
import '../../../widgets/state/empty_view.dart';
import '../../../widgets/state/error_view.dart';
import '../../../widgets/state/loading_view.dart';
import '../controllers/favorites_controller.dart';
import '../widgets/compare_bar.dart';
import '../widgets/favorite_tile.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: LocaleKeys.favoritesTitle.tr,
            subtitle: LocaleKeys.favoritesSubtitle.tr,
            actions: [
              IconButton(
                tooltip: LocaleKeys.voteMyVotes.tr,
                onPressed: () => Get.toNamed<void>(Routes.votes),
                icon: const Icon(Icons.how_to_vote_outlined),
              ),
              Obx(
                () => controller.hasFavorites
                    ? IconButton(
                        tooltip: LocaleKeys.favoritesClearAll.tr,
                        onPressed: controller.clearAll,
                        icon: const Icon(Icons.delete_sweep_outlined),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          Expanded(
            child: controller.obx(
              (entries) => _List(entries: entries ?? const []),
              onLoading: const LoadingView(),
              onEmpty: EmptyView(
                icon: Icons.favorite_rounded,
                accent: context.palette.girl,
                title: LocaleKeys.favoritesEmptyTitle.tr,
                message: LocaleKeys.favoritesEmptyMessage.tr,
              ),
              onError: (_) => ErrorView(onRetry: controller.load),
            ),
          ),
        ],
      ),
    );
  }
}

class _List extends GetView<FavoritesController> {
  const _List({required this.entries});

  final List<FavoriteEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            0,
            AppSpacing.page,
            120, // room for the compare bar
          ),
          itemCount: entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, i) => FavoriteTile(entry: entries[i])
              .animate(delay: (40 * i.clamp(0, 8)).ms)
              .fadeIn(duration: AppDurations.medium)
              .slideX(begin: 0.05, end: 0, curve: AppCurves.standard),
        ),
        if (entries.length >= FavoritesController.compareCount)
          const Positioned(
            left: AppSpacing.page,
            right: AppSpacing.page,
            bottom: AppSpacing.lg,
            child: CompareBar(),
          ),
      ],
    );
  }
}
