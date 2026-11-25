import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/name_card.dart';
import '../../../widgets/pill.dart';
import '../../../widgets/state/empty_view.dart';
import '../../../widgets/state/error_view.dart';
import '../../../widgets/state/loading_view.dart';
import '../controllers/matches_controller.dart';

class MatchesView extends GetView<MatchesController> {
  const MatchesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.matchesTitle.tr)),
      body: controller.obx(
        (entries) => _List(entries: entries ?? const []),
        onLoading: const LoadingView(),
        onEmpty: EmptyView(
          icon: Icons.favorite_border_rounded,
          accent: context.palette.girl,
          title: LocaleKeys.matchesEmptyTitle.tr,
          message: LocaleKeys.matchesEmptyMessage.tr,
        ),
        onError: (_) => ErrorView(onRetry: controller.load),
      ),
    );
  }
}

class _List extends GetView<MatchesController> {
  const _List({required this.entries});

  final List<MatchEntry> entries;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.xxxl,
      ),
      itemCount: entries.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Text(
            LocaleKeys.matchesSubtitle.tr,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: context.palette.inkMuted),
          );
        }
        final MatchEntry e = entries[i - 1];
        final String tag = nameHeroTag('matches', e.name.id);
        return Stack(
              children: [
                NameCard(
                  name: e.name,
                  heroTag: tag,
                  onTap: () => controller.open(e, tag),
                ),
                if (e.match.superLike)
                  Positioned(
                    right: AppSpacing.xxxl + AppSpacing.sm,
                    top: AppSpacing.lg,
                    child: Pill(
                      icon: Icons.star_rounded,
                      label: LocaleKeys.matchSuper.tr,
                      color: context.palette.gold,
                      background: context.palette.goldSoft,
                    ),
                  ),
              ],
            )
            .animate(delay: (40 * i.clamp(0, 8)).ms)
            .fadeIn(duration: AppDurations.medium)
            .slideY(begin: 0.06, end: 0, curve: AppCurves.standard);
      },
    );
  }
}
