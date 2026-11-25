import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../data/models/user_prefs.dart';
import '../../../translations/locale_keys.dart';
import '../controllers/onboarding_controller.dart';
import 'onboarding_slide.dart';
import 'option_tile.dart';

class ExpectingSlide extends GetView<OnboardingController> {
  const ExpectingSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<Expecting, (String, IconData, Color)> options = {
      Expecting.girl: (
        LocaleKeys.expectingGirl.tr,
        Icons.female_rounded,
        context.palette.girl,
      ),
      Expecting.boy: (
        LocaleKeys.expectingBoy.tr,
        Icons.male_rounded,
        context.palette.boy,
      ),
      Expecting.unknown: (
        LocaleKeys.expectingUnknown.tr,
        Icons.auto_awesome_rounded,
        context.palette.unisex,
      ),
    };
    return OnboardingSlide(
      icon: Icons.child_friendly_rounded,
      title: LocaleKeys.obExpectingTitle.tr,
      subtitle: LocaleKeys.obExpectingSubtitle.tr,
      child: Obx(
        () => Column(
          children: [
            for (final MapEntry<Expecting, (String, IconData, Color)> o
                in options.entries)
              OptionTile(
                label: o.value.$1,
                accent: o.value.$3,
                selected: controller.expecting.value == o.key,
                onTap: () => controller.setExpecting(o.key),
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: o.value.$3.withValues(alpha: 0.22),
                  child: Icon(o.value.$2, color: o.value.$3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
