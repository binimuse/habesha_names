import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/providers/ai_waitlist_remote.dart';
import '../data/providers/device_token_remote.dart';
import '../data/providers/firestore_favorites_remote_source.dart';
import '../data/providers/firestore_names_remote_source.dart';
import '../data/providers/firestore_partner_remote_source.dart';
import '../data/providers/isar_favorites_local_source.dart';
import '../data/providers/isar_names_local_source.dart';
import '../data/providers/names_seed_source.dart';
import '../data/providers/names_sync_state.dart';
import '../data/providers/store_gateway.dart';
import '../data/providers/vote_remote.dart';
import '../data/providers/storage_favorites_sync_state.dart';
import '../data/repositories/favorites_repository.dart';
import '../data/repositories/names_repository.dart';
import '../services/ai_waitlist_service.dart';
import '../services/analytics_service.dart';
import '../services/ads_service.dart';
import '../services/audio_service.dart';
import '../services/auth_service.dart';
import '../services/crash_reporter.dart';
import '../services/database_service.dart';
import '../services/favorites_service.dart';
import '../services/firebase_service.dart';
import '../services/partner_service.dart';
import '../services/notifications_service.dart';
import '../services/preferences_service.dart';
import '../services/purchase_service.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';
import '../services/report_service.dart';
import '../services/suggestion_service.dart';
import '../services/vote_service.dart';
import 'constants/app_constants.dart';

/// Everything that must be ready before the first frame.
Future<void> bootstrap() async {
  // Fonts are bundled in assets/google_fonts — never hit the network.
  GoogleFonts.config.allowRuntimeFetching = false;
  _registerFontLicenses();

  final StorageService storage = await Get.putAsync<StorageService>(
    () => StorageService().init(),
    permanent: true,
  );
  Get.put<SettingsService>(SettingsService(storage), permanent: true);
  Get.put<PreferencesService>(PreferencesService(storage), permanent: true);
  final PurchaseService purchases = await Get.putAsync<PurchaseService>(
    () => PurchaseService(InAppPurchaseGateway(), storage).init(),
    permanent: true,
  );
  Get.lazyPut<AudioService>(
    () => AudioService(offlineCache: () => purchases.isPremium.value),
    fenix: true,
  );
  unawaited(
    Get.putAsync<AdsService>(
      () => AdsService(purchases).init(),
      permanent: true,
    ),
  );

  final List<Object> services = await Future.wait<Object>([
    Get.putAsync<DatabaseService>(
      () => DatabaseService().init(),
      permanent: true,
    ),
    Get.putAsync<FirebaseService>(
      () => FirebaseService().init(),
      permanent: true,
    ),
  ]);
  final DatabaseService db = services[0] as DatabaseService;
  final FirebaseService firebase = services[1] as FirebaseService;
  await CrashReporter.init(firebaseAvailable: firebase.isAvailable);
  Get.put<AnalyticsService>(
    AnalyticsService.firebase(firebase),
    permanent: true,
  );

  final NamesRepository names = Get.put<NamesRepository>(
    NamesRepository(
      local: IsarNamesLocalSource(db.isar),
      seed: const AssetNamesSeedSource(),
      remote: FirestoreNamesRemoteSource(firebase),
      syncState: StorageNamesSyncState(storage),
    ),
    permanent: true,
  );

  final AuthService auth = Get.put<AuthService>(
    AuthService(firebase),
    permanent: true,
  );
  final FavoritesRepository favorites = FavoritesRepository(
    local: IsarFavoritesLocalSource(db.isar),
    remote: FirestoreFavoritesRemoteSource(auth),
    syncState: StorageFavoritesSyncState(storage),
  );
  await Get.putAsync<FavoritesService>(
    () => FavoritesService(favorites).init(),
    permanent: true,
  );

  await Get.putAsync<PartnerService>(
    () => PartnerService(FirestorePartnerRemoteSource(auth), storage).init(),
    permanent: true,
  );

  Get.put<AiWaitlistService>(
    AiWaitlistService(FirebaseAiWaitlistRemote(auth), storage),
    permanent: true,
  );

  Get.put<SuggestionService>(
    SuggestionService(FirestoreSuggestionRemote(auth)),
    permanent: true,
  );
  Get.put<ReportService>(
    ReportService(FirestoreReportRemote(auth)),
    permanent: true,
  );
  Get.put<VoteService>(VoteService(FirestoreVoteRemote(auth)), permanent: true);
  await Get.putAsync<NotificationsService>(
    () => NotificationsService(
      firebase,
      storage,
      auth: auth,
      devices: FirestoreDeviceTokenRemote(),
      locale: Get.find<SettingsService>().locale,
    ).init(),
    permanent: true,
  );

  // Seed on first launch, then pull server changes — both in the background.
  // Screens await `ensureReady()` through the repository's methods.
  unawaited(names.ensureReady().then((_) => names.syncFromFirestore()));
}

void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final MapEntry<String, String> entry
        in AppAssets.fontLicenses.entries) {
      final String text = await rootBundle.loadString(entry.value);
      yield LicenseEntryWithLineBreaks([entry.key], text);
    }
  });
}
