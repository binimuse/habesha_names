import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/extensions/context_x.dart';
import '../data/models/rarity.dart';
import '../translations/locale_keys.dart';
import 'pill.dart';

class RarityPill extends StatelessWidget {
  const RarityPill({super.key, required this.rarity});

  final Rarity rarity;

  static String label(Rarity r) => switch (r) {
    Rarity.popular => LocaleKeys.rarityPopular.tr,
    Rarity.unique => LocaleKeys.rarityUnique.tr,
    Rarity.rare => LocaleKeys.rarityRare.tr,
  };

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = switch (rarity) {
      Rarity.popular => (
        Icons.local_fire_department_rounded,
        context.colors.primary,
      ),
      Rarity.unique => (Icons.auto_awesome_rounded, context.palette.gold),
      Rarity.rare => (Icons.diamond_rounded, context.palette.unisex),
    };
    return Pill(
      icon: icon,
      label: label(rarity),
      color: Color.lerp(color, context.colors.onSurface, 0.25),
      background: color.withValues(alpha: 0.16),
    );
  }
}
