import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../translations/locale_keys.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colors.outlineVariant)),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.auto_awesome_outlined),
            selectedIcon: const Icon(Icons.auto_awesome),
            label: LocaleKeys.navDiscover.tr,
          ),
          NavigationDestination(
            icon: const Icon(Icons.play_circle_outline_rounded),
            selectedIcon: const Icon(Icons.play_circle_rounded),
            label: LocaleKeys.navReels.tr,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_rounded),
            selectedIcon: const Icon(Icons.saved_search_rounded),
            label: LocaleKeys.navSearch.tr,
          ),
          NavigationDestination(
            icon: const Icon(Icons.style_outlined),
            selectedIcon: const Icon(Icons.style),
            label: LocaleKeys.navSwipe.tr,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border_rounded),
            selectedIcon: const Icon(Icons.favorite_rounded),
            label: LocaleKeys.navFavorites.tr,
          ),
        ],
      ),
    );
  }
}
