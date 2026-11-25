// Renders every screen on a 5-inch phone (360×640 dp) in
//   • dark mode + Amharic UI, and
//   • light mode + English UI,
// fails on any layout overflow / exception, and writes screenshots to
// build/screen_audit/<config>/<screen>.png for visual review.
//
//   flutter test test/screens/screen_audit_test.dart
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habesha_names/app/data/models/couple.dart';
import 'package:habesha_names/app/data/models/family_vote.dart';
import 'package:habesha_names/app/data/models/favorite.dart';
import 'package:habesha_names/app/data/models/name_model.dart';
import 'package:habesha_names/app/data/providers/favorites_sources.dart';
import 'package:habesha_names/app/data/providers/names_seed_source.dart';
import 'package:habesha_names/app/data/providers/vote_remote.dart';
import 'package:habesha_names/app/data/repositories/favorites_repository.dart';
import 'package:habesha_names/app/data/repositories/names_repository.dart';
import 'package:habesha_names/app/routes/app_nav.dart';
import 'package:habesha_names/app/routes/app_pages.dart';
import 'package:habesha_names/app/services/ads_service.dart';
import 'package:habesha_names/app/services/ai_waitlist_service.dart';
import 'package:habesha_names/app/services/analytics_service.dart';
import 'package:habesha_names/app/services/audio_service.dart';
import 'package:habesha_names/app/services/auth_service.dart';
import 'package:habesha_names/app/services/favorites_service.dart';
import 'package:habesha_names/app/services/firebase_service.dart';
import 'package:habesha_names/app/services/notifications_service.dart';
import 'package:habesha_names/app/services/partner_service.dart';
import 'package:habesha_names/app/services/preferences_service.dart';
import 'package:habesha_names/app/services/purchase_service.dart';
import 'package:habesha_names/app/services/settings_service.dart';
import 'package:habesha_names/app/services/storage_service.dart';
import 'package:habesha_names/app/services/suggestion_service.dart';
import 'package:habesha_names/app/services/vote_service.dart';
import 'package:habesha_names/app/modules/shell/controllers/shell_controller.dart';
import 'package:habesha_names/app/theme/app_theme.dart';
import 'package:habesha_names/app/translations/app_translations.dart';

import '../ai/ai_waitlist_test.dart' show FakeWaitlistRemote;
import '../services/ads_purchase_test.dart' show FakeStore;
import '../support/fake_partner.dart';
import '../support/fakes.dart';
import '../support/memory_storage.dart';

// -- Fakes -----------------------------------------------------------------------

class _FavLocal implements FavoritesLocalSource {
  _FavLocal(this.rows);
  final List<StoredFavorite> rows;
  @override
  Future<List<StoredFavorite>> getAll() async => rows;
  @override
  Future<void> putAll(List<StoredFavorite> items) async => rows.addAll(items);
}

class _NoFavRemote implements FavoritesRemoteSource {
  @override
  bool get isAvailable => false;
  @override
  Future<String?> ensureUid() async => null;
  @override
  Future<List<Favorite>> pullChangedSince(String u, DateTime? s) async => [];
  @override
  Future<void> push(String u, List<Favorite> i) async {}
}

class _NoFavState implements FavoritesSyncState {
  @override
  DateTime? lastPulledAt(String uid) => null;
  @override
  Future<void> setLastPulledAt(String uid, DateTime v) async {}
}

class _VoteRemote implements VoteRemote {
  _VoteRemote(this.vote);
  final FamilyVote vote;
  @override
  bool get isAvailable => true;
  @override
  Future<String?> ensureUid() async => 'me';
  @override
  Future<String> create({
    required String ownerUid,
    required String title,
    required List<VoteOption> options,
  }) async => vote.id;
  @override
  Stream<FamilyVote?> watchVote(String id) => Stream.value(vote);
  @override
  Stream<List<Ballot>> watchBallots(String id) => Stream.value(const [
    Ballot(voterId: '1', voterName: 'አያቴ አልማዝ', choice: 'selam'),
    Ballot(voterId: '2', voterName: 'Kebede', choice: 'selam'),
    Ballot(voterId: '3', voterName: 'Abeba', choice: 'hiwot'),
  ]);
  @override
  Stream<List<FamilyVote>> watchMine(String uid) => Stream.value([vote]);
  @override
  Future<void> setOpen(String id, {required bool open}) async {}
}

class _SuggestRemote implements SuggestionRemote {
  @override
  bool get isAvailable => true;
  @override
  Future<String?> ensureUid() async => 'me';
  @override
  Future<void> add(Map<String, Object> data) async {}
}

class _NoSink implements AnalyticsSink {
  @override
  Future<void> log(String name, Map<String, Object> params) async {}
}

// -- Harness -----------------------------------------------------------------------

class AuditConfig {
  const AuditConfig(this.id, this.locale, this.mode);
  final String id;
  final Locale locale;
  final ThemeMode mode;
}

const List<AuditConfig> configs = [
  AuditConfig('dark_am_5inch', AppTranslations.amharic, ThemeMode.dark),
  AuditConfig('light_en_5inch', AppTranslations.english, ThemeMode.light),
];

late List<NameModel> realNames;

Future<void> registerServices(AuditConfig cfg) async {
  Get.testMode = true;
  final StorageService storage = MemoryStorageService();
  final SettingsService settings = Get.put(SettingsService(storage));
  settings.locale.value = cfg.locale;
  settings.themeMode.value = cfg.mode;
  Get.locale = cfg.locale;
  Get.put(PreferencesService(storage));
  Get.put<StorageService>(storage);
  final FirebaseService firebase = Get.put(FirebaseService());
  final AuthService auth = Get.put(AuthService(firebase));

  final RepoHarness h = RepoHarness(seed: realNames);
  Get.put<NamesRepository>(h.repo);
  await h.repo.ensureReady();

  final DateTime now = DateTime.utc(2026, 11, 20);
  await Get.putAsync(
    () => FavoritesService(
      FavoritesRepository(
        local: _FavLocal([
          for (final String id in ['hiwot', 'selam', 'amanuel'])
            StoredFavorite(
              Favorite(
                nameId: id,
                createdAt: now,
                updatedAt: now,
                note: id == 'selam' ? 'የአያቴ ስም ነው — Grandma’s name' : '',
              ),
              dirty: false,
            ),
        ]),
        remote: _NoFavRemote(),
        syncState: _NoFavState(),
      ),
    ).init(),
  );
  final PurchaseService purchases = await Get.putAsync(
    () => PurchaseService(FakeStore(), storage).init(),
  );
  Get.put(AdsService(purchases, enabled: false));
  Get.lazyPut(AudioService.new, fenix: true);
  await Get.putAsync(
    () => PartnerService(FakeRemote(FakeServer(), 'me'), storage).init(),
  );
  Get.put(AiWaitlistService(FakeWaitlistRemote(), storage));
  Get.put(
    VoteService(
      _VoteRemote(
        FamilyVote(
          id: 'v1',
          ownerUid: 'me',
          title: cfg.locale == AppTranslations.amharic
              ? 'የትኛውን ስም ይበልጥ ይወዱታል?'
              : 'Which name do you love most?',
          open: true,
          createdAt: now,
          options: [
            for (final id in ['hiwot', 'selam', 'amanuel'])
              VoteOption.fromName(realNames.firstWhere((n) => n.id == id)),
          ],
        ),
      ),
    ),
  );
  Get.put(NotificationsService(firebase, storage));
  Get.put(SuggestionService(_SuggestRemote()));
  Get.put(AnalyticsService(_NoSink(), enabled: false));
  auth.uid.value = 'me';
}

Future<void> loadIconFont() async {
  final File f = File(
    '${Platform.environment['FLUTTER_ROOT'] ?? 'C:/src/flutter'}'
    '/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
  );
  if (!f.existsSync()) return;
  final FontLoader loader = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
  await loader.load();
}

final GlobalKey _shotKey = GlobalKey();

Future<void> pumpRoute(
  WidgetTester t,
  AuditConfig cfg,
  String route, {
  Object? arguments,
  Future<void> Function(WidgetTester t)? after,
}) async {
  t.view.physicalSize = const Size(720, 1280); // 360×640 dp at 2×
  t.view.devicePixelRatio = 2;
  addTearDown(t.view.reset);

  await t.runAsync(() async {
    await loadIconFont();
    await registerServices(cfg);
  });
  await t.pumpWidget(
    RepaintBoundary(
      key: _shotKey,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        translations: AppTranslations(),
        locale: cfg.locale,
        fallbackLocale: AppTranslations.english,
        theme: AppTheme.light(cfg.locale),
        darkTheme: AppTheme.dark(cfg.locale),
        themeMode: cfg.mode,
        getPages: AppPages.routes,
        initialRoute: Routes.shell,
      ),
    ),
  );
  await t.runAsync(GoogleFonts.pendingFonts);
  if (route != Routes.shell) {
    unawaited(Get.toNamed<void>(route, arguments: arguments));
  }
  // Repeating animations (shimmer, loaders) never "settle"; pump in steps.
  for (int i = 0; i < 12; i++) {
    await t.pump(const Duration(milliseconds: 150));
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 5)),
    );
  }
  if (after != null) await after(t);
  await t.runAsync(GoogleFonts.pendingFonts);
  await t.pump(const Duration(milliseconds: 600));
}

Future<void> screenshot(WidgetTester t, AuditConfig cfg, String name) async {
  await t.runAsync(() async {
    final RenderRepaintBoundary b =
        _shotKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image img = await b.toImage(pixelRatio: 1.5);
    final ByteData? png = await img.toByteData(format: ui.ImageByteFormat.png);
    final File out = File('build/screen_audit/${cfg.id}/$name.png')
      ..createSync(recursive: true);
    await out.writeAsBytes(png!.buffer.asUint8List());
  });
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  realNames = NamesSeed.fromJsonString(
    File('assets/data/names.json').readAsStringSync(),
  ).names;

  tearDown(Get.reset);

  NameModel name(String id) => realNames.firstWhere((n) => n.id == id);

  Future<void> tab(WidgetTester t, int index) async {
    Get.find<ShellController>().selectIndex(index);
    for (int i = 0; i < 6; i++) {
      await t.pump(const Duration(milliseconds: 150));
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 5)),
      );
    }
  }

  final Map<String, (String, Object?, Future<void> Function(WidgetTester)?)>
  screens = {
    'splash': (Routes.splash, null, null),
    'onboarding': (Routes.onboarding, null, null),
    'tab_discover': (Routes.shell, null, null),
    'tab_reels': (Routes.shell, null, (t) => tab(t, 1)),
    'tab_search': (Routes.shell, null, (t) => tab(t, 2)),
    'tab_swipe': (Routes.shell, null, (t) => tab(t, 3)),
    'tab_favorites': (Routes.shell, null, (t) => tab(t, 4)),
    'settings': (Routes.settings, null, null),
    'name_detail': (
      Routes.nameDetail,
      NameDetailArgs(id: 'tsehay', name: name('tsehay')),
      null,
    ),
    'name_detail_long': (
      Routes.nameDetail,
      NameDetailArgs(id: 'amanuel', name: name('amanuel')),
      null,
    ),
    'compare': (Routes.compare, const CompareArgs('hiwot', 'amanuel'), null),
    'partner': (Routes.partner, null, null),
    'partner_waiting': (
      Routes.partner,
      null,
      (t) async {
        await t.runAsync(() => Get.find<PartnerService>().create());
        await t.pump(const Duration(milliseconds: 300));
      },
    ),
    'matches': (Routes.matches, null, null),
    'match': (
      Routes.match,
      NameMatch(
        nameId: 'selam',
        createdAt: DateTime.utc(2026),
        superLike: true,
      ),
      null,
    ),
    'full_name': (
      Routes.fullName,
      name('hiwot'),
      (t) async {
        await t.enterText(find.byType(TextField).first, 'Getachew');
        await t.enterText(find.byType(TextField).last, 'ተስፋዬ');
        for (int i = 0; i < 4; i++) {
          await t.pump(const Duration(milliseconds: 150));
          await t.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)),
          );
        }
      },
    ),
    'premium': (Routes.premium, null, null),
    'share_card': (Routes.shareCard, name('betelhem'), null),
    'reveal_video': (Routes.revealVideo, name('yared'), null),
    'vote_create': (Routes.voteCreate, null, null),
    'vote_results': (Routes.voteResults, 'v1', null),
    'votes': (Routes.votes, null, null),
  };

  for (final AuditConfig cfg in configs) {
    group(cfg.id, () {
      screens.forEach((id, s) {
        testWidgets(id, (t) async {
          await pumpRoute(t, cfg, s.$1, arguments: s.$2, after: s.$3);
          expect(t.takeException(), isNull);
          await screenshot(t, cfg, id);
        });
      });
    });
  }
}
