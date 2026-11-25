import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../translations/locale_keys.dart';
import '../controllers/onboarding_controller.dart';
import 'onboarding_slide.dart';
import 'option_tile.dart';

class LanguageSlide extends GetView<OnboardingController> {
  const LanguageSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingSlide(
      icon: Icons.translate_rounded,
      title: LocaleKeys.obLanguageTitle.tr,
      subtitle: LocaleKeys.obLanguageSubtitle.tr,
      child: Obx(
        () => Column(
          children: [
            for (final Locale l in controller.locales)
              OptionTile(
                label: l.languageCode == 'am'
                    ? LocaleKeys.languageAmharic.tr
                    : LocaleKeys.languageEnglish.tr,
                selected: controller.locale.value == l,
                onTap: () => controller.setLocale(l),
              ),
          ],
        ),
      ),
    );
  }
}
