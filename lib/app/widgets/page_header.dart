import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/extensions/context_x.dart';
import '../routes/app_pages.dart';
import '../theme/app_dimens.dart';
import '../translations/locale_keys.dart';

/// Large title + optional subtitle used at the top of each tab.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.useDisplayFont = false,
    this.showSettings = true,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;

  /// Use the serif display face (for hero titles like Discover).
  final bool useDisplayFont;
  final bool showSettings;

  /// Extra buttons shown before the settings button.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = context.textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: useDisplayFont
                      ? text.displaySmall
                      : text.headlineMedium,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: text.bodyMedium!.copyWith(
                      color: context.palette.inkMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ...actions,
          if (showSettings) const _SettingsButton(),
        ],
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: LocaleKeys.settings.tr,
      icon: const Icon(Icons.tune_rounded),
      onPressed: () => Get.toNamed<void>(Routes.settings),
    );
  }
}
