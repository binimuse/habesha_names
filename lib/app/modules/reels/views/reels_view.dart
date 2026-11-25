import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/state/empty_view.dart';
import '../../../widgets/state/error_view.dart';
import '../../../widgets/state/loading_view.dart';
import '../controllers/reels_controller.dart';
import '../widgets/reel_chips.dart';
import '../widgets/reel_page.dart';

class ReelsView extends GetView<ReelsController> {
  const ReelsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: controller.obx(
            (names) => PageView.builder(
              controller: controller.pageController,
              scrollDirection: Axis.vertical,
              // Keeps the next page built so the swipe feels instant.
              allowImplicitScrolling: true,
              onPageChanged: controller.onPageChanged,
              itemCount: names!.length,
              itemBuilder: (context, i) => ReelPage(name: names[i]),
            ),
            onLoading: const LoadingView(),
            onEmpty: SafeArea(
              child: EmptyView(
                icon: Icons.filter_alt_off_rounded,
                accent: context.palette.gold,
                title: LocaleKeys.reelsEmptyTitle.tr,
                message: LocaleKeys.reelsEmptyMessage.tr,
              ),
            ),
            onError: (_) => ErrorView(onRetry: controller.load),
          ),
        ),
        const Positioned(top: 0, left: 0, right: 0, child: ReelChips()),
      ],
    );
  }
}
