import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core/extensions/context_x.dart';
import '../services/favorites_service.dart';
import '../theme/app_dimens.dart';
import '../translations/locale_keys.dart';

/// Animated heart bound to [FavoritesService].
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.nameId, this.size = 24});

  final String nameId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final FavoritesService favorites = Get.find<FavoritesService>();
    return Obx(() {
      final bool on = favorites.isFavorite(nameId);
      return IconButton(
        tooltip: on
            ? LocaleKeys.detailUnfavorite.tr
            : LocaleKeys.detailFavorite.tr,
        onPressed: () {
          HapticFeedback.lightImpact();
          favorites.toggle(nameId);
        },
        icon: AnimatedSwitcher(
          duration: AppDurations.medium,
          switchInCurve: AppCurves.emphasized,
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(
            on ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(on),
            size: size,
            color: on ? context.palette.girl : context.palette.inkMuted,
          ),
        ),
      );
    });
  }
}
