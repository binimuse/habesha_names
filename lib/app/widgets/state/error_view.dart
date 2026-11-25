import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/extensions/context_x.dart';
import '../../translations/locale_keys.dart';
import 'state_message.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, this.message, this.onRetry});

  /// Already-translated message; falls back to a generic one.
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return StateMessage(
      icon: Icons.cloud_off_rounded,
      accent: context.colors.error,
      title: LocaleKeys.errorTitle.tr,
      message: message ?? LocaleKeys.errorMessage.tr,
      action: onRetry == null
          ? null
          : FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(LocaleKeys.retry.tr),
            ),
    );
  }
}
