import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/extensions/context_x.dart';

/// One-shot burst of hearts (like) or gold stars (super-like).
/// Give it a new [Key] to replay.
class HeartBurst extends StatelessWidget {
  const HeartBurst({super.key, this.superLike = false});

  final bool superLike;

  static const int _particles = 14;
  static const Duration _duration = Duration(milliseconds: 750);

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = superLike
        ? [context.palette.gold, context.colors.primary]
        : [context.palette.girl, context.colors.primary, context.palette.gold];
    final IconData icon = superLike
        ? Icons.star_rounded
        : Icons.favorite_rounded;
    final math.Random random = math.Random(key.hashCode);

    return IgnorePointer(
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 96, color: colors.first)
                .animate()
                .scale(
                  begin: const Offset(0.2, 0.2),
                  end: const Offset(1.3, 1.3),
                  duration: 350.ms,
                  curve: Curves.easeOutBack,
                )
                .then()
                .fadeOut(duration: 300.ms),
            for (int i = 0; i < _particles; i++)
              _particle(
                angle:
                    (i / _particles) * 2 * math.pi + random.nextDouble() * 0.4,
                distance: 110 + random.nextDouble() * 70,
                size: 14 + random.nextDouble() * 16,
                color: colors[i % colors.length],
                icon: icon,
                delay: random.nextInt(80),
              ),
          ],
        ),
      ),
    );
  }

  Widget _particle({
    required double angle,
    required double distance,
    required double size,
    required Color color,
    required IconData icon,
    required int delay,
  }) {
    final Offset end = Offset(math.cos(angle), math.sin(angle)) * distance;
    return Icon(icon, size: size, color: color)
        .animate(delay: delay.ms)
        .move(
          begin: Offset.zero,
          end: end,
          duration: _duration,
          curve: Curves.easeOutCubic,
        )
        .scale(begin: const Offset(0.3, 0.3), end: const Offset(1, 1))
        .rotate(begin: 0, end: (angle > math.pi ? -1 : 1) * 0.15)
        .fadeOut(delay: 350.ms, duration: 400.ms);
  }
}
