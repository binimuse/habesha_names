import 'package:flutter/material.dart';

import '../data/models/gender.dart';
import 'app_palette.dart';

extension GenderStyle on Gender {
  Color color(AppPalette p) => switch (this) {
    Gender.girl => p.girl,
    Gender.boy => p.boy,
    Gender.unisex => p.unisex,
  };

  Color soft(AppPalette p) => switch (this) {
    Gender.girl => p.girlSoft,
    Gender.boy => p.boySoft,
    Gender.unisex => p.unisexSoft,
  };

  IconData get icon => switch (this) {
    Gender.girl => Icons.female_rounded,
    Gender.boy => Icons.male_rounded,
    Gender.unisex => Icons.spa_rounded,
  };
}
