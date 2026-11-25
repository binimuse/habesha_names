import 'package:flutter/material.dart';

import '../core/extensions/context_x.dart';
import '../theme/app_dimens.dart';

/// Wrap of multi-select chips.
class ChoiceChipGroup<T> extends StatelessWidget {
  const ChoiceChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onToggle,
  });

  final List<T> options;
  final Set<T> selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final T o in options)
          FilterChip(
            label: Text(labelOf(o)),
            selected: selected.contains(o),
            showCheckmark: false,
            selectedColor: context.colors.primary.withValues(alpha: 0.16),
            labelStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: selected.contains(o) ? context.colors.primary : null,
            ),
            onSelected: (_) => onToggle(o),
          ),
      ],
    );
  }
}
