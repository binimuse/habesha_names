import 'package:flutter/material.dart';

import '../../../core/extensions/context_x.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import 'package:get/get.dart';

/// One attribute shown side by side for both names.
class CompareRow extends StatelessWidget {
  const CompareRow({
    super.key,
    required this.label,
    required this.left,
    required this.right,
    this.emphasize = false,
  });

  final String label;
  final String left;
  final String right;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return _RowShell(
      label: label,
      left: _value(context, left),
      right: _value(context, right),
    );
  }

  Widget _value(BuildContext context, String v) {
    final TextTheme text = Theme.of(context).textTheme;
    return Text(
      v.isEmpty ? '—' : v,
      textAlign: TextAlign.center,
      style: emphasize ? text.titleMedium : text.bodyMedium,
    );
  }
}

/// Popularity as two bars (0–100).
class PopularityRow extends StatelessWidget {
  const PopularityRow({super.key, required this.left, required this.right});

  final int left;
  final int right;

  @override
  Widget build(BuildContext context) {
    return _RowShell(
      label: LocaleKeys.comparePopularity.tr,
      left: _Bar(value: left),
      right: _Bar(value: right),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0, 100) / 100),
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
        const SizedBox(height: AppSpacing.xs),
        Text('$value', style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _RowShell extends StatelessWidget {
  const _RowShell({
    required this.label,
    required this.left,
    required this.right,
  });

  final String label;
  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: context.colors.outlineVariant),
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: context.palette.inkMuted,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: left),
                Container(
                  width: 1,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  color: context.colors.outlineVariant,
                ),
                Expanded(child: right),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
