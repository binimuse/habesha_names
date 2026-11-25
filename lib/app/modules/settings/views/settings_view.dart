import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_x.dart';
import '../../../theme/app_dimens.dart';
import '../../../translations/locale_keys.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_section.dart';
import '../widgets/suggest_name_sheet.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.settings.tr)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          AppSpacing.xxl,
        ),
        children: [
          SettingsSection(
            title: LocaleKeys.settingsAppearance.tr,
            child: Obx(
              () => SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: [
                  for (final ThemeMode mode in ThemeMode.values)
                    ButtonSegment(
                      value: mode,
                      label: Text(controller.themeModeLabelKey(mode).tr),
                    ),
                ],
                selected: {controller.themeMode.value},
                onSelectionChanged: (s) => controller.setThemeMode(s.first),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SettingsSection(
            title: LocaleKeys.settingsLanguage.tr,
            child: Obx(
              () => SegmentedButton<Locale>(
                showSelectedIcon: false,
                segments: [
                  for (final Locale l in controller.locales)
                    ButtonSegment(
                      value: l,
                      label: Text(controller.localeLabelKey(l).tr),
                    ),
                ],
                selected: {controller.locale.value},
                onSelectionChanged: (s) => controller.setLocale(s.first),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SettingsSection(
            title: LocaleKeys.settingsNotifications.tr,
            child: Obx(
              () => SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.wb_sunny_outlined),
                title: Text(LocaleKeys.settingsDailyName.tr),
                subtitle: Text(LocaleKeys.settingsDailyNameHint.tr),
                value: controller.dailyName,
                onChanged: controller.setDailyName,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SettingsSection(
            title: LocaleKeys.premiumTitle.tr,
            child: Column(
              children: [
                Obx(
                  () => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.workspace_premium_rounded,
                      color: context.palette.gold,
                    ),
                    title: Text(
                      controller.isPremium
                          ? LocaleKeys.premiumActive.tr
                          : LocaleKeys.premiumBuyNoPrice.tr,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: controller.openPremium,
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.restore_rounded),
                  title: Text(LocaleKeys.premiumRestore.tr),
                  onTap: controller.restorePurchases,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SettingsSection(
            title: LocaleKeys.settingsAbout.tr,
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lightbulb_outline_rounded),
                  title: Text(LocaleKeys.settingsSuggest.tr),
                  subtitle: Text(LocaleKeys.settingsSuggestHint.tr),
                  onTap: () => SuggestNameSheet.show(context),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.star_outline_rounded),
                  title: Text(LocaleKeys.settingsRate.tr),
                  onTap: controller.rateApp,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(LocaleKeys.settingsPrivacy.tr),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: controller.openPrivacy,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SettingsSection(
            title: LocaleKeys.settingsPreferences.tr,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.tune_rounded),
              title: Text(LocaleKeys.settingsPreferencesHint.tr),
              trailing: TextButton(
                onPressed: controller.editPreferences,
                child: Text(LocaleKeys.settingsEdit.tr),
              ),
              onTap: controller.editPreferences,
            ),
          ),
        ],
      ),
    );
  }
}
