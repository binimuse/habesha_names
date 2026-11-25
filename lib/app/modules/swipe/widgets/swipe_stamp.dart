import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/extensions/context_x.dart';
import '../../../theme/app_dimens.dart';

/// Heart / star / cross that fades in while a card is dragged.
/// [dx] and [dy] are the swiper's offset percentages (−100…100).
class SwipeStamp extends StatelessWidget {
  const SwipeStamp({super.key, required this.dx, required this.dy});

  final int dx;
  final int dy;

  @override
  Widget build(BuildContext context) {
    final bool up = dy < 0 && dy.abs() > dx.abs();
    final double strength = ((up ? dy : dx).abs() / 100).clamp(0, 1).toDouble();
    if (strength < 0.05) return const SizedBox.shrink();

    final (IconData icon, Color color, Alignment at, double tilt) = up
        ? (
            Icons.star_rounded,
            context.palette.gold,
            const Alignment(0, 0.55),
            0,
          )
        : dx > 0
        ? (
            Icons.favorite_rounded,
            context.palette.girl,
            const Alignment(-0.7, -0.75),
            -math.pi / 14,
          )
        : (
            Icons.close_rounded,
            context.palette.inkMuted,
            const Alignment(0.7, -0.75),
            math.pi / 14,
          );

    return IgnorePointer(
      child: Align(
        alignment: at,
        child: Opacity(
          opacity: strength,
          child: Transform.rotate(
            angle: tilt,
            child: Transform.scale(
              scale: 0.7 + 0.3 * strength,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.surface.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                ),
                child: Icon(icon, size: 44, color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
