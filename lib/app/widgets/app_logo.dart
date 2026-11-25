import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/extensions/context_x.dart';

/// Round mark: the fidel letter ሀ (first of the alphabet) on terracotta,
/// with a thin gold ring.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96, this.elevated = true});

  final double size;

  /// Soft drop shadow (off for launcher icons and splash images).
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final Color primary = context.colors.primary;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.05),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.palette.gold, width: size * 0.025),
        boxShadow: [
          if (elevated)
            BoxShadow(
              color: primary.withValues(alpha: 0.30),
              blurRadius: size * 0.35,
              offset: Offset(0, size * 0.12),
            ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(primary, Colors.white, 0.12)!,
              Color.lerp(primary, Colors.black, 0.18)!,
            ],
          ),
        ),
        child: Center(
          child: Text(
            'ሀ',
            style: GoogleFonts.notoSerifEthiopic(
              fontWeight: FontWeight.w700,
              fontSize: size * 0.46,
              height: 1,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
