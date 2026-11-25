import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/app_constants.dart';
import '../translations/app_translations.dart';
import 'storage_service.dart';

/// App-wide user preferences: theme mode and UI language.
class SettingsService extends GetxService {
  SettingsService(this._storage);

  final StorageService _storage;

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final Rx<Locale> locale = AppTranslations.fallbackLocale.obs;

  @override
  void onInit() {
    super.onInit();
    themeMode.value = _readThemeMode();
    locale.value = _readLocale();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (themeMode.value == mode) return;
    themeMode.value = mode;
    await _storage.write(StorageKeys.themeMode, mode.name);
  }

  Future<void> setLocale(Locale value) async {
    if (locale.value == value) return;
    locale.value = value;
    await Get.updateLocale(value);
    await _storage.write(StorageKeys.languageCode, value.languageCode);
  }

  ThemeMode _readThemeMode() {
    final String? stored = _storage.read<String>(StorageKeys.themeMode);
    return ThemeMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  /// Saved choice first; otherwise follow the device language.
  Locale _readLocale() {
    final String? stored = _storage.read<String>(StorageKeys.languageCode);
    return AppTranslations.resolve(stored ?? Get.deviceLocale?.languageCode);
  }
}
