import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/extensions/context_x.dart';
import '../../../theme/app_dimens.dart';

/// Shared layout: icon badge, title, subtitle, then the slide's options.
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xl,
        AppSpacing.page,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: context.palette.goldSoft,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: Icon(icon, color: context.palette.gold, size: 32),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(title, style: text.displaySmall),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    subtitle,
                    style: text.bodyLarge!.copyWith(
                      color: context.palette.inkMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  child,
                ]
                .animate(interval: 60.ms)
                .fadeIn(duration: AppDurations.medium)
                .slideY(begin: 0.08, end: 0, curve: AppCurves.standard),
      ),
    );
  }
}
