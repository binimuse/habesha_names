import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/tilet_band.dart';
import '../controllers/full_name_controller.dart';

/// The full name in Latin (Fraunces) and Ge'ez (Noto Serif Ethiopic).
class FullNameCard extends StatelessWidget {
  const FullNameCard({super.key, required this.preview});

  final FullNamePreview preview;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool approx = preview.approxGeez || preview.approxLatin;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const TiletBand(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              children: [
                _fit(
                  (preview.approxLatin ? '≈ ' : '') + preview.latin,
                  context.appText.nameDisplay.copyWith(fontSize: 38),
                ),
                const SizedBox(height: AppSpacing.sm),
                _fit(
                  (preview.approxGeez ? '≈ ' : '') + preview.geez,
                  context.appText.nameGeez.copyWith(
                    color: context.palette.inkMuted,
                  ),
                ),
                if (approx) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(LocaleKeys.fullNameApprox.tr, style: text.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// One line, scaled down to fit long names.
  Widget _fit(String value, TextStyle style) => AnimatedSwitcher(
    duration: AppDurations.fast,
    child: FittedBox(
      key: ValueKey(value),
      fit: BoxFit.scaleDown,
      child: Text(value, maxLines: 1, style: style),
    ),
  );
}
