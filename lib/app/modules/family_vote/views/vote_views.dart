import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../data/models/family_vote.dart';
import '../../../data/models/name_model.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/gender_style.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/state/empty_view.dart';
import '../../../widgets/state/error_view.dart';
import '../../../widgets/state/loading_view.dart';
import '../../../widgets/tilet_band.dart';
import '../controllers/vote_controllers.dart';

// -----------------------------------------------------------------------------
// Create
// -----------------------------------------------------------------------------

class VoteCreateView extends GetView<VoteCreateController> {
  const VoteCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.voteCreateTitle.tr)),
      body: !controller.isAvailable
          ? EmptyView(
              icon: Icons.cloud_off_rounded,
              title: LocaleKeys.voteUnavailable.tr,
            )
          : controller.obx(
              (names) => _Picker(names: names ?? const []),
              onLoading: const LoadingView(),
              onEmpty: EmptyView(
                icon: Icons.favorite_rounded,
                accent: context.palette.girl,
                title: LocaleKeys.favoritesEmptyTitle.tr,
                message: LocaleKeys.favoritesEmptyMessage.tr,
              ),
              onError: (_) => ErrorView(onRetry: controller.load),
            ),
    );
  }
}

class _Picker extends GetView<VoteCreateController> {
  const _Picker({required this.names});

  final List<NameModel> names;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            0,
            AppSpacing.page,
            AppSpacing.md,
          ),
          child: Text(
            LocaleKeys.voteCreateHint.tr,
            style: text.bodyMedium!.copyWith(color: context.palette.inkMuted),
          ),
        ),
        Expanded(
          child: Obx(
            () => ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              children: [
                for (final NameModel n in names)
                  CheckboxListTile(
                    value: controller.selected.contains(n.id),
                    onChanged: (_) => controller.toggle(n.id),
                    activeColor: context.colors.primary,
                    secondary: CircleAvatar(
                      backgroundColor: n.gender.soft(context.palette),
                      child: Icon(
                        n.gender.icon,
                        color: n.gender.color(context.palette),
                      ),
                    ),
                    title: Text(n.nameLatin, style: text.titleMedium),
                    subtitle: Text(n.nameGeez),
                  ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (controller.errorKey.value != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text(
                        controller.errorKey.value!.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.colors.error),
                      ),
                    ),
                  FilledButton.icon(
                    onPressed: controller.canCreate ? controller.create : null,
                    icon: const Icon(Icons.how_to_vote_rounded),
                    label: Text(
                      '${LocaleKeys.voteCreate.tr} '
                      '(${controller.selected.length}/${FamilyVote.maxOptions})',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Results
// -----------------------------------------------------------------------------

class VoteResultsView extends GetView<VoteResultsController> {
  const VoteResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.voteResults.tr),
        actions: [
          IconButton(
            tooltip: LocaleKeys.voteShareAgain.tr,
            onPressed: controller.share,
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value) return const LoadingView();
        final VoteTally? tally = controller.tally;
        final FamilyVote? vote = controller.vote.value;
        if (controller.missing.value || tally == null || vote == null) {
          return EmptyView(
            icon: Icons.how_to_vote_outlined,
            title: LocaleKeys.detailNotFound.tr,
          );
        }
        return _Results(vote: vote, tally: tally);
      }),
    );
  }
}

class _Results extends GetView<VoteResultsController> {
  const _Results({required this.vote, required this.tally});

  final FamilyVote vote;
  final VoteTally tally;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Set<String> leaders = tally.leaders;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.xxxl,
      ),
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              const TiletBand(height: 14),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Text(
                      vote.title,
                      style: text.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      vote.open
                          ? LocaleKeys.voteBallots.trParams({
                              'count': '${tally.total}',
                            })
                          : LocaleKeys.voteClosed.tr,
                      style: text.bodyMedium!.copyWith(
                        color: context.palette.inkMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    InkWell(
                      onTap: () => Clipboard.setData(
                        ClipboardData(text: controller.link),
                      ),
                      child: Text(
                        controller.link,
                        style: text.labelMedium!.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (tally.total == 0)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              LocaleKeys.voteNoBallots.tr,
              textAlign: TextAlign.center,
              style: text.bodyMedium!.copyWith(color: context.palette.inkMuted),
            ),
          ),
        for (final OptionTally o in tally.options)
          _OptionBar(
            tally: o,
            total: tally.total,
            leading: leaders.contains(o.option.nameId),
          ),
        const SizedBox(height: AppSpacing.xl),
        if (vote.open)
          OutlinedButton.icon(
            onPressed: controller.closeVoting,
            icon: const Icon(Icons.lock_outline_rounded),
            label: Text(LocaleKeys.voteCloseAction.tr),
          ),
      ],
    );
  }
}

class _OptionBar extends StatelessWidget {
  const _OptionBar({
    required this.tally,
    required this.total,
    required this.leading,
  });

  final OptionTally tally;
  final int total;
  final bool leading;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final double share = total == 0 ? 0 : tally.votes / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (leading)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: context.palette.gold,
                    ),
                  ),
                Expanded(
                  child: Text(
                    '${tally.option.latin} · ${tally.option.geez}',
                    style: text.titleMedium,
                  ),
                ),
                Text('${tally.votes}', style: text.titleLarge),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: share),
                duration: AppDurations.slow,
                curve: AppCurves.standard,
                builder: (_, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 10,
                  color: leading
                      ? context.colors.primary
                      : context.palette.gold,
                  backgroundColor: context.palette.goldSoft,
                ),
              ),
            ),
            if (tally.voters.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                LocaleKeys.voteVoters.trParams({
                  'names': tally.voters.join(', '),
                }),
                style: text.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// My votes
// -----------------------------------------------------------------------------

class VotesView extends GetView<VotesController> {
  const VotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.voteMyVotes.tr)),
      floatingActionButton: controller.isAvailable
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: controller.create,
              icon: const Icon(Icons.how_to_vote_rounded),
              label: Text(LocaleKeys.voteAction.tr),
            )
          : null,
      body: !controller.isAvailable
          ? EmptyView(
              icon: Icons.cloud_off_rounded,
              title: LocaleKeys.voteUnavailable.tr,
            )
          : Obx(
              () => controller.votes.isEmpty
                  ? EmptyView(
                      icon: Icons.how_to_vote_outlined,
                      accent: context.palette.gold,
                      title: LocaleKeys.voteEmptyTitle.tr,
                      message: LocaleKeys.voteCreateHint.tr,
                    )
                  : ListView(
                      padding: const EdgeInsets.all(AppSpacing.page),
                      children: [
                        for (final FamilyVote v in controller.votes)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: AppCard(
                              onTap: () => controller.open(v),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  v.open
                                      ? Icons.how_to_vote_rounded
                                      : Icons.lock_outline_rounded,
                                  color: context.palette.gold,
                                ),
                                title: Text(
                                  v.options.map((o) => o.latin).join(' · '),
                                ),
                                subtitle: Text(
                                  v.open ? v.title : LocaleKeys.voteClosed.tr,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
    );
  }
}
