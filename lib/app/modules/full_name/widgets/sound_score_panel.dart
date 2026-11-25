import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/text/name_sound_score.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/app_card.dart';
import '../controllers/full_name_controller.dart';

/// Score ring, three sub-scores and tips. Null [score] → prompt to type.
class SoundScorePanel extends StatelessWidget {
  const SoundScorePanel({super.key, required this.score});

  final NameSoundScore? score;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final NameSoundScore? s = score;
    if (s == null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          LocaleKeys.fullNameEnterFather.tr,
          textAlign: TextAlign.center,
          style: text.bodyMedium!.copyWith(color: context.palette.inkMuted),
        ),
      );
    }
    final SoundGrade grade = FullNameController.gradeOf(s.total);
    final Color color = _gradeColor(context, grade);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LocaleKeys.fullNameScore.tr.toUpperCase(),
            textAlign: TextAlign.center,
            style: text.labelMedium!.copyWith(
              color: context.palette.inkMuted,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: _Ring(value: s.total, color: color),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _gradeLabel(grade),
            textAlign: TextAlign.center,
            style: text.titleLarge!.copyWith(color: color),
          ),
          const SizedBox(height: AppSpacing.xl),
          _Bar(label: LocaleKeys.scoreBalance.tr, check: s.balance),
          _Bar(label: LocaleKeys.scoreStarts.tr, check: s.starts),
          _Bar(label: LocaleKeys.scoreFlow.tr, check: s.flow),
          const SizedBox(height: AppSpacing.md),
          for (final SoundNote n in s.notes)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    n == SoundNote.balanced
                        ? Icons.check_circle_rounded
                        : Icons.tips_and_updates_outlined,
                    size: 18,
                    color: n == SoundNote.balanced
                        ? context.palette.unisex
                        : context.palette.gold,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(_noteKey(n).tr, style: text.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static Color _gradeColor(BuildContext context, SoundGrade g) => switch (g) {
    SoundGrade.great => context.palette.unisex,
    SoundGrade.good => context.palette.gold,
    SoundGrade.ok => context.palette.boy,
    SoundGrade.clash => context.colors.primary,
  };

  static String _gradeLabel(SoundGrade g) => switch (g) {
    SoundGrade.great => LocaleKeys.gradeGreat.tr,
    SoundGrade.good => LocaleKeys.gradeGood.tr,
    SoundGrade.ok => LocaleKeys.gradeOk.tr,
    SoundGrade.clash => LocaleKeys.gradeClash.tr,
  };

  static String _noteKey(SoundNote n) => switch (n) {
    SoundNote.tooShort => LocaleKeys.noteTooShort,
    SoundNote.tooLong => LocaleKeys.noteTooLong,
    SoundNote.uneven => LocaleKeys.noteUneven,
    SoundNote.sameLength => LocaleKeys.noteSameLength,
    SoundNote.sameStartFather => LocaleKeys.noteSameStartFather,
    SoundNote.sameStartAll => LocaleKeys.noteSameStartAll,
    SoundNote.runTogether => LocaleKeys.noteRunTogether,
    SoundNote.vowelClash => LocaleKeys.noteVowelClash,
    SoundNote.sameAsFather => LocaleKeys.noteSameAsFather,
    SoundNote.balanced => LocaleKeys.noteBalanced,
  };
}

class _Ring extends StatelessWidget {
  const _Ring({required this.value, required this.color});

  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value / 100),
      duration: AppDurations.slow,
      curve: AppCurves.standard,
      builder: (context, v, _) => SizedBox.square(
        dimension: 128,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: v,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              color: color,
              backgroundColor: color.withValues(alpha: 0.15),
            ),
            Center(
              child: Text(
                '${(v * 100).round()}',
                style: context.appText.nameDisplay.copyWith(fontSize: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.label, required this.check});

  final String label;
  final SoundCheck check;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: text.labelLarge)),
              Text('${check.score}/${check.max}', style: text.labelMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: check.ratio),
              duration: AppDurations.slow,
              curve: AppCurves.standard,
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                color: context.palette.gold,
                backgroundColor: context.palette.goldSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
