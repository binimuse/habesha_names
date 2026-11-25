import 'package:flutter/material.dart';

import '../core/extensions/context_x.dart';

/// A woven border inspired by *tilet*, the patterned band on Habesha
/// clothing: gold edge stripes around a row of diamonds and small crosses.
class TiletBand extends StatelessWidget {
  const TiletBand({super.key, this.height = 26});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _TiletPainter(
            primary: context.colors.primary,
            gold: context.palette.gold,
            green: context.palette.unisex,
            ground: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
      ),
    );
  }
}

class _TiletPainter extends CustomPainter {
  _TiletPainter({
    required this.primary,
    required this.gold,
    required this.green,
    required this.ground,
  });

  final Color primary;
  final Color gold;
  final Color green;
  final Color ground;

  @override
  void paint(Canvas canvas, Size size) {
    final double h = size.height;
    final double stripe = h * 0.1;
    final Paint p = Paint()..isAntiAlias = true;

    // Edge stripes: gold outside, green inside.
    p.color = gold;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, stripe), p);
    canvas.drawRect(Rect.fromLTWH(0, h - stripe, size.width, stripe), p);
    p.color = green;
    canvas.drawRect(
      Rect.fromLTWH(0, stripe * 1.6, size.width, stripe * 0.6),
      p,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h - stripe * 2.2, size.width, stripe * 0.6),
      p,
    );

    // Motif row.
    final double top = stripe * 2.6;
    final double bottom = h - stripe * 2.6;
    final double mid = (top + bottom) / 2;
    final double halfH = (bottom - top) / 2;
    final double cell = h * 1.1;
    final int count = (size.width / cell).ceil() + 1;
    final double offset = (size.width - (count - 1) * cell) / 2;

    for (int i = 0; i < count; i++) {
      final double cx = offset + i * cell;
      _diamond(canvas, p..color = primary, cx, mid, cell * 0.3, halfH);
      _diamond(canvas, p..color = ground, cx, mid, cell * 0.17, halfH * 0.56);
      canvas.drawCircle(Offset(cx, mid), halfH * 0.18, p..color = gold);
      _cross(canvas, p..color = gold, cx + cell / 2, mid, halfH * 0.55);
    }
  }

  void _diamond(Canvas c, Paint p, double cx, double cy, double hw, double hh) {
    c.drawPath(
      Path()
        ..moveTo(cx, cy - hh)
        ..lineTo(cx + hw, cy)
        ..lineTo(cx, cy + hh)
        ..lineTo(cx - hw, cy)
        ..close(),
      p,
    );
  }

  void _cross(Canvas c, Paint p, double cx, double cy, double r) {
    final double t = r * 0.38;
    c.drawRect(
      Rect.fromCenter(center: Offset(cx, cy), width: t, height: r * 2),
      p,
    );
    c.drawRect(
      Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: t),
      p,
    );
  }

  @override
  bool shouldRepaint(_TiletPainter old) =>
      old.primary != primary ||
      old.gold != gold ||
      old.green != green ||
      old.ground != ground;
}
