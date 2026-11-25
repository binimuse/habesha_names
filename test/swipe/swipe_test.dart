import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habesha_names/app/data/models/favorite.dart';
import 'package:habesha_names/app/data/models/gender.dart';
import 'package:habesha_names/app/data/models/name_model.dart';
import 'package:habesha_names/app/data/models/user_prefs.dart';
import 'package:habesha_names/app/data/providers/favorites_sources.dart';
import 'package:habesha_names/app/data/providers/seen_names_store.dart';
import 'package:habesha_names/app/data/repositories/favorites_repository.dart';
import 'package:habesha_names/app/data/repositories/names_repository.dart';
import 'package:habesha_names/app/data/search/swipe_deck.dart';
import 'package:habesha_names/app/modules/swipe/controllers/swipe_controller.dart';
import 'package:habesha_names/app/modules/swipe/views/swipe_view.dart';
import 'package:habesha_names/app/services/favorites_service.dart';
import 'package:habesha_names/app/services/partner_service.dart';
import 'package:habesha_names/app/services/preferences_service.dart';
import 'package:habesha_names/app/theme/app_theme.dart';
import 'package:habesha_names/app/translations/app_translations.dart';

import '../support/fake_partner.dart';
import '../support/fakes.dart';
import '../support/memory_storage.dart';

class MemorySeenStore implements SeenNamesStore {
  Set<String> ids = {};
  @override
  Set<String> load() => {...ids};
  @override
  Future<void> save(Set<String> value) async => ids = {...value};
}

class _FavLocal implements FavoritesLocalSource {
  final List<StoredFavorite> rows = [];
  @override
  Future<List<StoredFavorite>> getAll() async => rows;
  @override
  Future<void> putAll(List<StoredFavorite> items) async => rows.addAll(items);
}

class _FavRemote implements FavoritesRemoteSource {
  @override
  bool get isAvailable => false;
  @override
  Future<String?> ensureUid() async => null;
  @override
  Future<List<Favorite>> pullChangedSince(String u, DateTime? s) async => [];
  @override
  Future<void> push(String u, List<Favorite> i) async {}
}

class _FavState implements FavoritesSyncState {
  @override
  DateTime? lastPulledAt(String uid) => null;
  @override
  Future<void> setLastPulledAt(String uid, DateTime v) async {}
}

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 5));

/// Everything a SwipeController needs, wired with fakes.
class SwipeHarness {
  late FakeServer server;
  late MemorySeenStore seen;
  late FavoritesService favorites;
  late PreferencesService prefs;
  late PartnerService me;
  late PartnerService partner;
  late NamesRepository names;

  Future<void> init({Expecting expecting = Expecting.unknown}) async {
    server = FakeServer();
    seen = MemorySeenStore();
    names = RepoHarness().repo;
    favorites = await FavoritesService(
      FavoritesRepository(
        local: _FavLocal(),
        remote: _FavRemote(),
        syncState: _FavState(),
      ),
    ).init();
    prefs = PreferencesService(MemoryStorageService())..onInit();
    await prefs.save(UserPrefs(expecting: expecting));
    me = await PartnerService(
      FakeRemote(server, 'me'),
      MemoryStorageService(),
    ).init();
    partner = await PartnerService(
      FakeRemote(server, 'partner'),
      MemoryStorageService(),
    ).init();
  }

  SwipeController controller() =>
      SwipeController(names, prefs, favorites, seen, me)..onInit();

  void dispose() {
    favorites.onClose();
    me.onClose();
    partner.onClose();
  }
}

void main() {
  group('SwipeDeck.build', () {
    test('excludes seen and favorites, keeps everything else', () {
      final List<NameModel> deck = SwipeDeck.build(
        sampleNames,
        seen: {'hiwot', 'hana'},
        exclude: {'abebe'},
        seed: 1,
      );
      expect(deck.map((n) => n.id), isNot(contains('hiwot')));
      expect(deck.map((n) => n.id), isNot(contains('abebe')));
      expect(deck, hasLength(sampleNames.length - 3));
    });

    test('same seed → same order', () {
      List<String> order(int seed) => [
        for (final n in SwipeDeck.build(
          sampleNames,
          seen: const {},
          exclude: const {},
          seed: seed,
        ))
          n.id,
      ];
      expect(order(42), order(42));
    });
  });

  group('SwipeChoice', () {
    test('maps swiper directions', () {
      expect(
        SwipeChoice.fromDirection(CardSwiperDirection.right),
        SwipeChoice.like,
      );
      expect(
        SwipeChoice.fromDirection(CardSwiperDirection.top),
        SwipeChoice.superLike,
      );
      expect(
        SwipeChoice.fromDirection(CardSwiperDirection.left),
        SwipeChoice.skip,
      );
    });
  });

  group('SwipeController', () {
    late SwipeHarness h;
    late SwipeController c;

    setUp(() async {
      Get.testMode = true;
      h = SwipeHarness();
      await h.init(expecting: Expecting.boy);
      c = h.controller();
      await c.load();
    });

    tearDown(() {
      h.dispose();
      Get.reset();
    });

    test('deck follows preferences (boy → boy + unisex)', () {
      expect(c.deck, isNotEmpty);
      expect(
        c.deck.map((n) => n.gender),
        everyElement(isIn([Gender.boy, Gender.unisex])),
      );
    });

    test('quick gender filter overrides the preference', () async {
      c.toggleGender(Gender.unisex);
      await settle();
      expect(c.deck.map((n) => n.gender).toSet(), {Gender.unisex});
    });

    test(
      'like / super-like favorite and mark seen; skip does not favorite',
      () async {
        final List<NameModel> d = c.deck;
        c.onSwipe(0, 1, CardSwiperDirection.right);
        c.onSwipe(1, 2, CardSwiperDirection.top);
        c.onSwipe(2, 3, CardSwiperDirection.left);
        await settle();

        expect(h.favorites.isFavorite(d[0].id), isTrue);
        expect(h.favorites.isFavorite(d[1].id), isTrue);
        expect(h.favorites.isFavorite(d[2].id), isFalse);
        expect(h.seen.ids, {d[0].id, d[1].id, d[2].id});
        expect(c.index.value, 3);
        expect(c.burst.value, 2);
        expect(c.burstKind.value, SwipeChoice.superLike);
      },
    );

    test('likes reach the linked partner (super flag kept)', () async {
      final String code = await h.me.create();
      await h.partner.join(code);
      await settle();
      final List<NameModel> d = c.deck;
      c.onSwipe(0, 1, CardSwiperDirection.top);
      c.onSwipe(1, 2, CardSwiperDirection.left);
      await settle();
      expect(h.server.likes[code], {'me_${d[0].id}': true});
    });

    test('undo restores index and un-favorites / un-likes', () async {
      final String code = await h.me.create();
      await h.partner.join(code);
      await settle();
      final NameModel first = c.deck.first;
      c.onSwipe(0, 1, CardSwiperDirection.right);
      await settle();
      expect(c.canUndo.value, isTrue);

      c.onUndo(1, 0, CardSwiperDirection.right);
      await settle();
      expect(c.index.value, 0);
      expect(h.favorites.isFavorite(first.id), isFalse);
      expect(h.server.likes[code], isEmpty);
      expect(h.seen.ids, isEmpty);
      expect(c.canUndo.value, isFalse);
    });

    test('end of deck → finished; start over refills', () async {
      final int size = c.deck.length;
      for (int i = 0; i < size; i++) {
        c.onSwipe(i, i + 1 < size ? i + 1 : null, CardSwiperDirection.left);
      }
      c.onEnd();
      await settle();
      expect(c.finished.value, isTrue);
      expect(c.remaining, 0);

      await c.startOver();
      expect(c.finished.value, isFalse);
      expect(c.deck, hasLength(size));
    });

    test('a new session does not repeat seen names', () async {
      final NameModel first = c.deck.first;
      c.onSwipe(0, 1, CardSwiperDirection.left);
      await settle();
      final SwipeController next = h.controller();
      await next.load();
      expect(next.deck.map((n) => n.id), isNot(contains(first.id)));
    });

    test('both partners like the same name → match announced', () async {
      final String code = await h.me.create();
      await h.partner.join(code);
      await settle();
      final List<String> announced = [];
      h.me.newMatches.listen((m) => announced.add(m.nameId));

      final NameModel name = c.deck.first;
      await h.partner.recordLike(name.id);
      c.onSwipe(0, 1, CardSwiperDirection.right);
      await settle();
      expect(announced, [name.id]);
    });
  });

  group('SwipeView', () {
    // Async work started in the fake-async zone needs pumps; work on objects
    // created in runAsync needs real time. Alternate both.
    Future<void> flush(WidgetTester t) async {
      for (int i = 0; i < 5; i++) {
        await t.runAsync(settle);
        await t.pump();
      }
    }

    late SwipeHarness h;

    Future<SwipeController> pump(WidgetTester tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      Get.testMode = true;
      await tester.binding.setSurfaceSize(const Size(400, 860));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      h = SwipeHarness();
      await tester.runAsync(() => h.init());
      final SwipeController c = Get.put(h.controller());
      await tester.runAsync(c.load);
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: AppTranslations.english,
          theme: AppTheme.light(AppTranslations.english),
          home: const Scaffold(body: SwipeView()),
        ),
      );
      await tester.runAsync(GoogleFonts.pendingFonts);
      await tester.pumpAndSettle();
      return c;
    }

    tearDown(() {
      h.dispose();
      Get.reset();
    });

    testWidgets('drag right likes the top card; burst plays', (t) async {
      final SwipeController c = await pump(t);
      final NameModel top = c.deck.first;
      await t.drag(find.byType(CardSwiper), const Offset(320, 0));
      await t.pumpAndSettle();
      await flush(t);
      expect(c.index.value, 1);
      expect(h.favorites.isFavorite(top.id), isTrue);
      expect(c.burst.value, 1);
      expect(t.takeException(), isNull);
      await t.pump(const Duration(seconds: 3)); // favorites sync timer
    });

    testWidgets('buttons: skip, super like, undo', (t) async {
      final SwipeController c = await pump(t);
      await t.tap(find.byTooltip('Skip'));
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('Super like'));
      await t.pumpAndSettle();
      await flush(t);
      expect(c.index.value, 2);
      expect(c.burstKind.value, SwipeChoice.superLike);

      await t.tap(find.byTooltip('Undo'));
      await t.pumpAndSettle();
      await flush(t);
      expect(c.index.value, 1);
      expect(t.takeException(), isNull);
      await t.pump(const Duration(seconds: 3));
    });
  });
}
