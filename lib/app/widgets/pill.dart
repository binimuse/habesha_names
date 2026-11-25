import 'package:flutter/material.dart';

import '../core/extensions/context_x.dart';
import '../data/models/gender.dart';
import '../core/utils/labels.dart';
import '../theme/app_dimens.dart';
import '../theme/gender_style.dart';

/// Small rounded label, e.g. "Girl", "2 syllables", "Verified".
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.background,
  });

  final String label;
  final IconData? icon;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final Color fg = color ?? context.palette.inkMuted;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: background ?? context.palette.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}

class GenderPill extends StatelessWidget {
  const GenderPill({super.key, required this.gender});

  final Gender gender;

  @override
  Widget build(BuildContext context) {
    final Color c = gender.color(context.palette);
    return Pill(
      label: Labels.gender(gender),
      icon: gender.icon,
      color: Color.lerp(c, context.colors.onSurface, 0.35),
      background: gender.soft(context.palette),
    );
  }
}
