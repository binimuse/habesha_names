import 'package:flutter/animation.dart';

/// Spacing scale (4pt grid). Prefer these over magic numbers.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Horizontal padding for page content.
  static const double page = 20;
}

abstract final class AppRadius {
  static const double sm = 12;
  static const double md = 16;
  static const double card = 20;
  static const double sheet = 28;
  static const double pill = 999;
}

abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

abstract final class AppCurves {
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutBack;
}
