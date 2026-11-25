import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../controllers/search_controller.dart';

/// Horizontal A–Z / ሀ–ፐ strip with a script toggle.
class LetterIndex extends GetView<NameSearchController> {
  const LetterIndex({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Obx(() {
        final String? selected = controller.filter.value.firstLetter;
        final List<String> letters = controller.letters;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          itemCount: letters.length + 1,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs + 2),
          itemBuilder: (context, i) {
            if (i == 0) return const _ScriptToggle();
            final String l = letters[i - 1];
            return _LetterChip(
              letter: l,
              selected: l == selected,
              onTap: () => controller.selectLetter(l),
            );
          },
        );
      }),
    );
  }
}

class _ScriptToggle extends GetView<NameSearchController> {
  const _ScriptToggle();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool latin = controller.script.value == IndexScript.latin;
      return ActionChip(
        avatar: const Icon(Icons.swap_horiz_rounded, size: 18),
        label: Text(
          latin
              ? LocaleKeys.searchIndexLatin.tr
              : LocaleKeys.searchIndexGeez.tr,
        ),
        onPressed: controller.toggleScript,
        tooltip: LocaleKeys.searchBrowseTitle.tr,
      );
    });
  }
}

class _LetterChip extends StatelessWidget {
  const _LetterChip({
    required this.letter,
    required this.selected,
    required this.onTap,
  });

  final String letter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color primary = context.colors.primary;
    return AnimatedContainer(
      duration: AppDurations.fast,
      width: 44,
      decoration: BoxDecoration(
        color: selected ? primary : context.colors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: selected ? primary : context.colors.outline),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Text(
              letter,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: selected
                    ? context.colors.onPrimary
                    : context.colors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
