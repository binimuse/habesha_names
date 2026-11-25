import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/labels.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/choice_chip_group.dart';
import '../controllers/onboarding_controller.dart';
import 'onboarding_slide.dart';

class PreferencesSlide extends GetView<OnboardingController> {
  const PreferencesSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return OnboardingSlide(
      icon: Icons.tune_rounded,
      title: LocaleKeys.obPrefsTitle.tr,
      subtitle: LocaleKeys.obPrefsSubtitle.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LocaleKeys.obFaiths.tr, style: text.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Obx(
            () => ChoiceChipGroup<String>(
              options: controller.faithOptions,
              selected: controller.faiths.toSet(),
              labelOf: Labels.faith,
              onToggle: controller.toggleFaith,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(LocaleKeys.obLanguages.tr, style: text.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Obx(
            () => ChoiceChipGroup<String>(
              options: controller.languageOptions,
              selected: controller.languages.toSet(),
              labelOf: Labels.language,
              onToggle: controller.toggleLanguage,
            ),
          ),
        ],
      ),
    );
  }
}
