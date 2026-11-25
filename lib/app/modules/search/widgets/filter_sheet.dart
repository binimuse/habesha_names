import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/labels.dart';
import '../../../data/models/gender.dart';
import '../../../data/models/name_filter.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../../../widgets/choice_chip_group.dart';
import '../controllers/search_controller.dart';

/// Bottom sheet editing [NameSearchController.draft]; applied on confirm.
class FilterSheet extends GetView<NameSearchController> {
  const FilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    Get.find<NameSearchController>().openDraft();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scroll) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              0,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    LocaleKeys.searchFilters.tr,
                    style: text.headlineSmall,
                  ),
                ),
                TextButton(
                  onPressed: controller.resetDraft,
                  child: Text(LocaleKeys.filterReset.tr),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final NameFilter d = controller.draft.value;
              return ListView(
                controller: scroll,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                ),
                children: [
                  _Section(
                    title: LocaleKeys.filterGender.tr,
                    child: ChoiceChipGroup<Gender>(
                      options: Gender.values,
                      selected: d.genders,
                      labelOf: Labels.gender,
                      onToggle: controller.toggleDraftGender,
                    ),
                  ),
                  _Section(
                    title: LocaleKeys.filterLanguage.tr,
                    child: ChoiceChipGroup<String>(
                      options: controller.languageOptions,
                      selected: d.languages,
                      labelOf: Labels.language,
                      onToggle: controller.toggleDraftLanguage,
                    ),
                  ),
                  _Section(
                    title: LocaleKeys.filterFaith.tr,
                    child: ChoiceChipGroup<String>(
                      options: controller.faithOptions,
                      selected: d.faiths,
                      labelOf: Labels.faith,
                      onToggle: controller.toggleDraftFaith,
                    ),
                  ),
                  if (controller.themeOptions.isNotEmpty)
                    _Section(
                      title: LocaleKeys.filterTheme.tr,
                      child: ChoiceChipGroup<String>(
                        options: controller.themeOptions,
                        selected: d.themes,
                        labelOf: Labels.theme,
                        onToggle: controller.toggleDraftTheme,
                      ),
                    ),
                  _Section(
                    title: LocaleKeys.filterSyllables.tr,
                    child: ChoiceChipGroup<SyllableBucket>(
                      options: SyllableBucket.values,
                      selected: {?SyllableBucket.of(d)},
                      labelOf: _syllableLabel,
                      onToggle: controller.toggleDraftSyllables,
                    ),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(LocaleKeys.filterEasyAbroad.tr),
                    value: d.easyAbroad ?? false,
                    onChanged: controller.setDraftEasyAbroad,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              );
            }),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                AppSpacing.lg,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    controller.applyDraft();
                    Navigator.of(context).pop();
                  },
                  child: Text(LocaleKeys.filterApply.tr),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _syllableLabel(SyllableBucket b) => switch (b) {
    SyllableBucket.short => LocaleKeys.filterSyllablesShort.tr,
    SyllableBucket.medium => LocaleKeys.filterSyllablesMedium.tr,
    SyllableBucket.long => LocaleKeys.filterSyllablesLong.tr,
  };
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
