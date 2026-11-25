import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../discover/views/discover_view.dart';
import '../../favorites/views/favorites_view.dart';
import '../../reels/views/reels_view.dart';
import '../../search/views/search_view.dart';
import '../../swipe/views/swipe_view.dart';
import '../controllers/shell_controller.dart';
import '../widgets/app_bottom_nav.dart';

class ShellView extends GetView<ShellController> {
  const ShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final int index = controller.currentTab.value.index;
      return PopScope(
        canPop: controller.isOnFirstTab,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.onBackFromOtherTab();
        },
        child: Scaffold(
          body: IndexedStack(
            index: index,
            children: const [
              DiscoverView(),
              ReelsView(),
              SearchView(),
              SwipeView(),
              FavoritesView(),
            ],
          ),
          bottomNavigationBar: AppBottomNav(
            selectedIndex: index,
            onSelected: controller.selectIndex,
          ),
        ),
      );
    });
  }
}
