import 'package:flutter/material.dart';

import '../../../core/extensions/context_x.dart';
import '../../../theme/app_dimens.dart';

/// Large single-choice option with an animated selected state.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
    this.accent,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final Color a = accent ?? context.colors.primary;
    final BorderRadius radius = BorderRadius.circular(AppRadius.card);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AnimatedContainer(
        duration: AppDurations.medium,
        curve: AppCurves.standard,
        decoration: BoxDecoration(
          color: selected ? a.withValues(alpha: 0.14) : context.colors.surface,
          borderRadius: radius,
          border: Border.all(
            color: selected ? a : context.colors.outline,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? null : context.palette.cardShadow,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg + 2),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: AppSpacing.lg),
                  ],
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  AnimatedScale(
                    scale: selected ? 1 : 0,
                    duration: AppDurations.medium,
                    curve: AppCurves.emphasized,
                    child: Icon(Icons.check_circle_rounded, color: a),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
