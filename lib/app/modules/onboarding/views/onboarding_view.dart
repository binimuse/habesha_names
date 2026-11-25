import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/tilet_band.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/expecting_slide.dart';
import '../widgets/language_slide.dart';
import '../widgets/page_dots.dart';
import '../widgets/preferences_slide.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TiletBand(height: 18),
            const _TopBar(),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: const [
                  LanguageSlide(),
                  ExpectingSlide(),
                  PreferencesSlide(),
                ],
              ),
            ),
            Obx(
              () => PageDots(
                count: OnboardingController.pageCount,
                index: controller.page.value,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: SizedBox(
                width: double.infinity,
                child: Obx(
                  () => FilledButton(
                    onPressed: controller.next,
                    child: Text(
                      !controller.isLastPage
                          ? LocaleKeys.obNext.tr
                          : controller.editing
                          ? LocaleKeys.obSave.tr
                          : LocaleKeys.obStart.tr,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends GetView<OnboardingController> {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Obx(
        () => Row(
          children: [
            AnimatedOpacity(
              opacity: controller.canGoBack ? 1 : 0,
              duration: AppDurations.fast,
              child: IconButton(
                tooltip: LocaleKeys.obBack.tr,
                onPressed: controller.canGoBack ? controller.goBack : null,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const Spacer(),
            if (!controller.isLastPage && !controller.editing)
              TextButton(
                onPressed: controller.finish,
                child: Text(LocaleKeys.obSkip.tr),
              ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
