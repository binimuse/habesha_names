import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/utils/labels.dart';
import '../../../data/models/name_model.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/pill.dart';

/// Titled card used for every detail section.
class DetailCard extends StatelessWidget {
  const DetailCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.md,
      ),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: context.palette.gold),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: context.palette.inkMuted,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class MeaningSection extends StatelessWidget {
  const MeaningSection({super.key, required this.name});

  final NameModel name;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final String secondary = Labels.secondaryMeaning(name);
    return DetailCard(
      icon: Icons.auto_stories_rounded,
      title: LocaleKeys.detailMeaning.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Labels.meaning(name),
            style: text.headlineSmall!.copyWith(fontWeight: FontWeight.w600),
          ),
          if (secondary.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              secondary,
              style: text.bodyLarge!.copyWith(color: context.palette.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class OriginSection extends StatelessWidget {
  const OriginSection({super.key, required this.name});

  final NameModel name;

  @override
  Widget build(BuildContext context) {
    final String origin = Labels.origin(name);
    return DetailCard(
      icon: Icons.public_rounded,
      title: LocaleKeys.detailOrigin.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (origin.isNotEmpty)
            Text(origin, style: Theme.of(context).textTheme.bodyLarge),
          if (name.languages.isNotEmpty || name.faiths.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final String l in name.languages)
                  Pill(
                    icon: Icons.translate_rounded,
                    label: Labels.language(l),
                  ),
                for (final String f in name.faiths)
                  Pill(
                    icon: Icons.brightness_7_rounded,
                    label: Labels.faith(f),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class NicknamesSection extends StatelessWidget {
  const NicknamesSection({super.key, required this.name});

  final NameModel name;

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      icon: Icons.favorite_outline_rounded,
      title: LocaleKeys.detailNicknames.tr,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final String n in name.nicknames)
            Pill(
              label: n,
              color: context.colors.primary,
              background: context.colors.primary.withValues(alpha: 0.10),
            ),
        ],
      ),
    );
  }
}

class FamousSection extends StatelessWidget {
  const FamousSection({super.key, required this.name});

  final NameModel name;

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      icon: Icons.star_rounded,
      title: LocaleKeys.detailFamous.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final String person in name.famous)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 6, color: context.palette.gold),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      person,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
