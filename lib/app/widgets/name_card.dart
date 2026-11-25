import 'package:flutter/material.dart';

import '../core/extensions/context_x.dart';
import '../core/utils/labels.dart';
import '../data/models/name_model.dart';
import '../theme/app_dimens.dart';
import '../theme/gender_style.dart';
import 'favorite_button.dart';
import 'name_title.dart';
import 'pill.dart';

/// Hero tag shared by a card and the detail page it opens.
String nameHeroTag(String section, String nameId) => 'name/$section/$nameId';

/// Card for a name. [compact] is the carousel variant (fixed width).
class NameCard extends StatelessWidget {
  const NameCard({
    super.key,
    required this.name,
    required this.heroTag,
    this.onTap,
    this.compact = false,
  });

  final NameModel name;
  final String heroTag;
  final VoidCallback? onTap;
  final bool compact;

  static const double compactWidth = 176;
  static const double compactHeight = 196;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppRadius.card);
    final Color tint = name.gender.soft(context.palette);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: context.palette.cardShadow,
      ),
      child: Material(
        color: context.colors.surface,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [tint, context.colors.surface],
                stops: const [0, 0.75],
              ),
            ),
            child: compact ? _compact(context) : _regular(context),
          ),
        ),
      ),
    );
  }

  Widget _regular(BuildContext context) {
    final String meaning = Labels.meaning(name);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg + 2,
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: heroTag,
                  child: NameTitle(name: name, height: 62),
                ),
                if (meaning.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    meaning,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: context.palette.inkMuted,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                GenderPill(gender: name.gender),
              ],
            ),
          ),
          FavoriteButton(nameId: name.id),
        ],
      ),
    );
  }

  Widget _compact(BuildContext context) {
    final String meaning = Labels.meaning(name);
    return SizedBox(
      width: compactWidth,
      height: compactHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.xs,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  name.gender.icon,
                  size: 18,
                  color: name.gender.color(context.palette),
                ),
                const Spacer(),
                FavoriteButton(nameId: name.id, size: 22),
              ],
            ),
            const Spacer(),
            Hero(
              tag: heroTag,
              child: NameTitle(name: name, height: 58),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              meaning,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
