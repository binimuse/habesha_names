/// Keys used with [StorageService]. Keep them stable — renaming a key
/// silently drops the user's saved value.
abstract final class StorageKeys {
  static const String themeMode = 'settings.theme_mode';
  static const String languageCode = 'settings.language_code';
  static const String namesLastSyncedAt = 'names.last_synced_at';
  static const String namesSeedVersion = 'names.seed_version';
}

abstract final class AppAssets {
  static const String fontsDir = 'assets/google_fonts';
  static const String matchLottie = 'assets/lottie/match.json';

  /// Font family (as shown on the licenses page) → bundled OFL file.
  static const Map<String, String> fontLicenses = {
    'Plus Jakarta Sans': '$fontsDir/OFL-PlusJakartaSans.txt',
    'Fraunces': '$fontsDir/OFL-Fraunces.txt',
    'Noto Sans Ethiopic': '$fontsDir/OFL-NotoSansEthiopic.txt',
    'Noto Serif Ethiopic': '$fontsDir/OFL-NotoSerifEthiopic.txt',
  };
}

/// Deployment-specific settings.
abstract final class AppConfig {
  /// Public family-vote page on Firebase Hosting (see hosting/public).
  static const String voteBaseUrl = 'https://habesha-baby-names.web.app/v/';
}

abstract final class AppLinks {
  /// Privacy policy (hosting/public/privacy.html).
  static const String privacy = 'https://habesha-baby-names.web.app/privacy';

  /// Google Play listing (used when the in-app review sheet isn't available).
  static const String playStore =
      'https://play.google.com/store/apps/details?id=com.codewave.et.habesha_names';
}
