import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../controllers/search_controller.dart';
import 'filter_sheet.dart';

class SearchField extends GetView<NameSearchController> {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.textController,
            onChanged: controller.onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: LocaleKeys.searchHint.tr,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: Obx(
                () => controller.hasQuery
                    ? IconButton(
                        tooltip: LocaleKeys.searchClear.tr,
                        icon: const Icon(Icons.close_rounded),
                        onPressed: controller.clearQuery,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        const _FilterButton(),
      ],
    );
  }
}

class _FilterButton extends GetView<NameSearchController> {
  const _FilterButton();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final int active = controller.filter.value.activeCount;
      return Badge(
        isLabelVisible: active > 0,
        label: Text('$active'),
        backgroundColor: context.colors.primary,
        child: IconButton.filledTonal(
          tooltip: LocaleKeys.searchFilters.tr,
          iconSize: 22,
          style: IconButton.styleFrom(
            fixedSize: const Size(56, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          onPressed: () => FilterSheet.show(context),
          icon: const Icon(Icons.tune_rounded),
        ),
      );
    });
  }
}
