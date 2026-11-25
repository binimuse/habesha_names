import 'package:flutter/material.dart';

import '../data/models/name_model.dart';
import '../theme/app_dimens.dart';
import 'name_card.dart';

/// Horizontal row of compact name cards.
class NameCarousel extends StatelessWidget {
  const NameCarousel({
    super.key,
    required this.section,
    required this.names,
    required this.onTap,
  });

  /// Unique per carousel on a page; part of each card's Hero tag.
  final String section;
  final List<NameModel> names;
  final void Function(NameModel name, String heroTag) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Extra room so card shadows aren't clipped.
      height: NameCard.compactHeight + AppSpacing.xl,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.xs,
          AppSpacing.page,
          AppSpacing.lg,
        ),
        itemCount: names.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, i) {
          final String tag = nameHeroTag(section, names[i].id);
          return NameCard(
            name: names[i],
            heroTag: tag,
            compact: true,
            onTap: () => onTap(names[i], tag),
          );
        },
      ),
    );
  }
}
