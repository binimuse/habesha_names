import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../controllers/full_name_controller.dart';
import '../widgets/full_name_card.dart';
import '../widgets/sound_score_panel.dart';

class FullNameView extends GetView<FullNameController> {
  const FullNameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.fullNameTitle.tr)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          AppSpacing.xxxl,
        ),
        children: [
          Obx(() => FullNameCard(preview: controller.preview.value)),
          const SizedBox(height: AppSpacing.xl),
          _NameField(
            controller: controller.father,
            label: LocaleKeys.fullNameFather.tr,
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          _NameField(
            controller: controller.grandfather,
            label: LocaleKeys.fullNameGrandfather.tr,
            icon: Icons.elderly_rounded,
          ),
          const SizedBox(height: AppSpacing.xl),
          Obx(() => SoundScorePanel(score: controller.preview.value.score)),
        ],
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: LocaleKeys.fullNameHint.tr,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
