import 'package:flutter/material.dart';

import '../../../core/extensions/context_x.dart';
import '../../../theme/app_dimens.dart';

class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: AppDurations.medium,
            curve: AppCurves.standard,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            width: i == index ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == index
                  ? context.colors.primary
                  : context.colors.outline,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
      ],
    );
  }
}
