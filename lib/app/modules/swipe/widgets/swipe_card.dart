import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/utils/labels.dart';
import '../../../data/models/name_model.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/gender_style.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/name_title.dart';
import '../../../widgets/pill.dart';
import '../../../widgets/tilet_band.dart';

/// The big card in the Swipe deck.
class SwipeCard extends StatelessWidget {
  const SwipeCard({super.key, required this.name, this.heroTag});

  final NameModel name;

  /// Only the top card carries a Hero tag.
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final BorderRadius radius = BorderRadius.circular(AppRadius.sheet);
    final Widget title = NameTitle(
      name: name,
      height: 150,
      alignment: Alignment.center,
    );
    final String origin = Labels.origin(name);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: context.palette.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                name.gender.soft(context.palette),
                context.colors.surface,
              ],
              stops: const [0, 0.7],
            ),
          ),
          child: Column(
            children: [
              const TiletBand(height: 22),
              // Title block scales down on short screens (5-inch phones).
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) => Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: box.maxWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                              ),
                              child: heroTag == null
                                  ? title
                                  : Hero(tag: heroTag!, child: title),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                              ),
                              child: Text(
                                Labels.meaning(name),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: text.headlineSmall,
                              ),
                            ),
                            if (origin.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                origin,
                                textAlign: TextAlign.center,
                                style: text.bodyMedium!.copyWith(
                                  color: context.palette.inkMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  GenderPill(gender: name.gender),
                  if (name.syllables > 0)
                    Pill(
                      icon: Icons.graphic_eq_rounded,
                      label: LocaleKeys.detailSyllables.trParams({
                        'count': '${name.syllables}',
                      }),
                    ),
                  if (name.easyAbroad)
                    Pill(
                      icon: Icons.flight_takeoff_rounded,
                      label: LocaleKeys.detailEasyAbroad.tr,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
