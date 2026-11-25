import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habesha_names/app/data/models/favorite.dart';
import 'package:habesha_names/app/data/models/name_model.dart';
import 'package:habesha_names/app/data/providers/favorites_sources.dart';
import 'package:habesha_names/app/data/repositories/favorites_repository.dart';
import 'package:habesha_names/app/modules/compare/widgets/compare_row.dart';
import 'package:habesha_names/app/modules/discover/widgets/name_of_day_card.dart';
import 'package:habesha_names/app/modules/name_detail/widgets/detail_sections.dart';
import 'package:habesha_names/app/services/favorites_service.dart';
import 'package:habesha_names/app/theme/app_theme.dart';
import 'package:habesha_names/app/translations/app_translations.dart';
import 'package:habesha_names/app/widgets/app_logo.dart';
import 'package:habesha_names/app/widgets/name_card.dart';
import 'package:habesha_names/app/widgets/name_carousel.dart';
import 'package:habesha_names/app/widgets/tilet_band.dart';

import '../support/fakes.dart';

class _NoRemote implements FavoritesRemoteSource {
  @override
  bool get isAvailable => false;
  @override
  Future<String?> ensureUid() async => null;
  @override
  Future<List<Favorite>> pullChangedSince(String uid, DateTime? s) async => [];
  @override
  Future<void> push(String uid, List<Favorite> items) async {}
}

class _MemLocal implements FavoritesLocalSource {
  final List<StoredFavorite> rows = [];
  @override
  Future<List<StoredFavorite>> getAll() async => rows;
  @override
  Future<void> putAll(List<StoredFavorite> items) async => rows.addAll(items);
}

class _NoState implements FavoritesSyncState {
  @override
  DateTime? lastPulledAt(String uid) => null;
  @override
  Future<void> setLastPulledAt(String uid, DateTime value) async {}
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() async {
    Get.testMode = true;
    final FavoritesRepository repo = FavoritesRepository(
      local: _MemLocal(),
      remote: _NoRemote(),
      syncState: _NoState(),
    );
    await Get.putAsync<FavoritesService>(() => FavoritesService(repo).init());
  });

  tearDown(Get.reset);

  final NameModel long = name(
    'wolde',
    latin: 'Woldemariam Gebremedhin',
    geez: 'ወልደማርያም ገብረመድኅን',
    meaningEn: 'Son of Mary, servant of the Saviour — a long meaning line',
    meaningAm: 'የማርያም ልጅ',
    nicknames: ['Wolde', 'Mari'],
  );
  final List<NameModel> names = [...sampleNames.take(4), long];

  for (final (Locale locale, Brightness b) in [
    (AppTranslations.english, Brightness.light),
    (AppTranslations.amharic, Brightness.dark),
  ]) {
    testWidgets('components render without errors ($locale, ${b.name})', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 3200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: locale,
          theme: b == Brightness.light
              ? AppTheme.light(locale)
              : AppTheme.dark(locale),
          home: Scaffold(
            body: ListView(
              children: [
                const TiletBand(),
                const Center(child: AppLogo()),
                NameOfDayCard(name: long, onTap: (_, _) {}),
                for (final NameModel n in names)
                  NameCard(name: n, heroTag: nameHeroTag('t', n.id)),
                NameCarousel(section: 'c', names: names, onTap: (_, _) {}),
                MeaningSection(name: long),
                OriginSection(name: long),
                NicknamesSection(name: long),
                const CompareRow(
                  label: 'Meaning',
                  left: 'Life',
                  right: 'Peace',
                ),
                const PopularityRow(left: 90, right: 40),
              ],
            ),
          ),
        ),
      );
      await tester.runAsync(GoogleFonts.pendingFonts);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Woldemariam Gebremedhin'), findsWidgets);
    });
  }

  testWidgets('heart toggles a favorite', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: AppTranslations.english,
        theme: AppTheme.light(AppTranslations.english),
        home: Scaffold(
          body: NameCard(name: sampleNames.first, heroTag: 'h'),
        ),
      ),
    );
    await tester.runAsync(GoogleFonts.pendingFonts);
    final FavoritesService favs = Get.find<FavoritesService>();
    expect(favs.isFavorite('hiwot'), isFalse);

    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(favs.isFavorite('hiwot'), isTrue);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    // Let the debounced background sync timer fire.
    await tester.pump(const Duration(seconds: 3));
  });
}
