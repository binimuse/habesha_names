import 'package:flutter/material.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/utils/labels.dart';
import '../../../data/models/name_model.dart';
import '../../../theme/app_dimens.dart';
import '../../../theme/gender_style.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/favorite_button.dart';
import '../../../widgets/name_card.dart';
import '../../../widgets/name_title.dart';
import '../../../widgets/pill.dart';
import '../../../widgets/tilet_band.dart';
import 'package:get/get.dart';

/// Hero card at the top of Discover.
class NameOfDayCard extends StatelessWidget {
  const NameOfDayCard({super.key, required this.name, required this.onTap});

  final NameModel name;
  final void Function(NameModel name, String heroTag) onTap;

  static const String section = 'name-of-day';

  @override
  Widget build(BuildContext context) {
    final String heroTag = nameHeroTag(section, name.id);
    final BorderRadius radius = BorderRadius.circular(AppRadius.card + 4);
    final TextTheme text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: context.palette.cardShadow,
      ),
      child: Material(
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        color: context.colors.surface,
        child: InkWell(
          onTap: () => onTap(name, heroTag),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  name.gender.soft(context.palette),
                  context.colors.surface,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TiletBand(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.wb_sunny_rounded,
                            size: 16,
                            color: context.palette.gold,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            LocaleKeys.discoverNameOfDay.tr.toUpperCase(),
                            style: text.labelMedium!.copyWith(
                              color: context.palette.gold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Spacer(),
                          FavoriteButton(nameId: name.id),
                        ],
                      ),
                      Hero(
                        tag: heroTag,
                        child: NameTitle(name: name, height: 96),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(Labels.meaning(name), style: text.bodyLarge),
                      const SizedBox(height: AppSpacing.lg),
                      GenderPill(gender: name.gender),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
