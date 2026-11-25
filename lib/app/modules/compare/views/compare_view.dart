import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/utils/labels.dart';
import '../../../data/models/name_model.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/gender_style.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/name_title.dart';
import '../../../widgets/state/empty_view.dart';
import '../../../widgets/state/error_view.dart';
import '../../../widgets/state/loading_view.dart';
import '../../../widgets/tilet_band.dart';
import '../controllers/compare_controller.dart';
import '../widgets/compare_row.dart';

class CompareView extends GetView<CompareController> {
  const CompareView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.compareTitle.tr)),
      body: controller.obx(
        (pair) => _Table(pair: pair!),
        onLoading: const LoadingView(),
        onEmpty: EmptyView(
          icon: Icons.compare_arrows_rounded,
          title: LocaleKeys.detailNotFound.tr,
        ),
        onError: (_) => ErrorView(onRetry: controller.load),
      ),
    );
  }
}

class _Table extends StatelessWidget {
  const _Table({required this.pair});

  final ComparePair pair;

  @override
  Widget build(BuildContext context) {
    final NameModel a = pair.first;
    final NameModel b = pair.second;
    String yesNo(bool v) =>
        v ? LocaleKeys.compareYes.tr : LocaleKeys.compareNo.tr;
    String join(List<String> codes, String Function(String) label) =>
        codes.isEmpty ? '—' : codes.map(label).join(', ');

    final List<Widget> rows = [
      CompareRow(
        label: LocaleKeys.detailMeaning.tr,
        left: Labels.meaning(a),
        right: Labels.meaning(b),
        emphasize: true,
      ),
      CompareRow(
        label: LocaleKeys.detailOrigin.tr,
        left: Labels.origin(a),
        right: Labels.origin(b),
      ),
      CompareRow(
        label: LocaleKeys.filterGender.tr,
        left: Labels.gender(a.gender),
        right: Labels.gender(b.gender),
      ),
      CompareRow(
        label: LocaleKeys.filterSyllables.tr,
        left: '${a.syllables}',
        right: '${b.syllables}',
      ),
      CompareRow(
        label: LocaleKeys.compareLanguages.tr,
        left: join(a.languages, Labels.language),
        right: join(b.languages, Labels.language),
      ),
      CompareRow(
        label: LocaleKeys.compareFaiths.tr,
        left: join(a.faiths, Labels.faith),
        right: join(b.faiths, Labels.faith),
      ),
      CompareRow(
        label: LocaleKeys.filterEasyAbroad.tr,
        left: yesNo(a.easyAbroad),
        right: yesNo(b.easyAbroad),
      ),
      CompareRow(
        label: LocaleKeys.detailPronunciation.tr,
        left: a.pronunciation ?? '—',
        right: b.pronunciation ?? '—',
      ),
      PopularityRow(left: a.popularity, right: b.popularity),
    ];

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
                child: Row(
                  children: [
                    Expanded(child: _Head(name: a)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Text(
                        '&',
                        style: context.appText.nameDisplay.copyWith(
                          fontSize: 28,
                          color: context.palette.gold,
                        ),
                      ),
                    ),
                    Expanded(child: _Head(name: b)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...rows
            .animate(interval: 40.ms)
            .fadeIn(duration: AppDurations.medium)
            .slideY(begin: 0.05, end: 0, curve: AppCurves.standard),
      ],
    );
  }
}

class _Head extends StatelessWidget {
  const _Head({required this.name});

  final NameModel name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: name.gender.color(context.palette),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        NameTitle(name: name, height: 64, alignment: Alignment.center),
      ],
    );
  }
}
