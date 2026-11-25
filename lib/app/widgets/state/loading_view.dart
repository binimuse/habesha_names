import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/extensions/context_x.dart';
import '../../theme/app_dimens.dart';
import '../../translations/locale_keys.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox.square(
            dimension: 32,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            LocaleKeys.loading.tr,
            style: context.textTheme.bodyMedium!.copyWith(
              color: context.palette.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
