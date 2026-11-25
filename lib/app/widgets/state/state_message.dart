import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/extensions/context_x.dart';
import '../../theme/app_dimens.dart';

/// Centered icon + title + message (+ optional action). Shared layout for
/// empty and error states so they look identical across screens.
class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.accent,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  /// Icon tint; defaults to the primary colour.
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color tint = accent ?? context.colors.primary;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child:
            Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _IconBadge(icon: icon, color: tint),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      title,
                      style: text.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    if (message != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        message!,
                        style: text.bodyMedium!.copyWith(
                          color: context.palette.inkMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (action != null) ...[
                      const SizedBox(height: AppSpacing.xl),
                      action!,
                    ],
                  ],
                )
                .animate()
                .fadeIn(
                  duration: AppDurations.medium,
                  curve: AppCurves.standard,
                )
                .slideY(begin: 0.06, end: 0, curve: AppCurves.standard),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 40, color: color),
    );
  }
}
