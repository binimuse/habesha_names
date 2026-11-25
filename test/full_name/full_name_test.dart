import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habesha_names/app/core/constants/app_constants.dart';
import 'package:habesha_names/app/data/models/couple.dart';
import 'package:habesha_names/app/modules/full_name/controllers/full_name_controller.dart';
import 'package:habesha_names/app/modules/full_name/views/full_name_view.dart';
import 'package:habesha_names/app/modules/match/controllers/match_controller.dart';
import 'package:habesha_names/app/modules/match/views/match_view.dart';
import 'package:habesha_names/app/services/partner_service.dart';
import 'package:habesha_names/app/theme/app_theme.dart';
import 'package:habesha_names/app/translations/app_translations.dart';
import 'package:lottie/lottie.dart';

import '../support/fake_partner.dart';
import '../support/fakes.dart';
import '../support/memory_storage.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  group('FullNameController', () {
    late FullNameController c;
    late MemoryStorageService storage;

    setUp(() {
      storage = MemoryStorageService();
      c = FullNameController(
        sampleNames.firstWhere((n) => n.id == 'hiwot'),
        RepoHarness().repo,
        storage,
      );
    });

    test('given name only: no score yet', () async {
      await c.refreshPreview();
      expect(c.preview.value.latin, 'Hiwot');
      expect(c.preview.value.geez, 'ሕይወት');
      expect(c.preview.value.score, isNull);
    });

    test('known names use the database spelling (no ≈)', () async {
      c.father.text = 'abebe';
      c.grandfather.text = 'ፀሐይ';
      await c.refreshPreview();
      final FullNamePreview p = c.preview.value;
      expect(p.latin, 'Hiwot Abebe Tsehay');
      expect(p.geez, 'ሕይወት አበበ ፀሐይ');
      expect(p.approxGeez, isFalse);
      expect(p.approxLatin, isFalse);
      expect(p.score, isNotNull);
    });

    test('unknown names are transliterated and marked approximate', () async {
      c.father.text = 'getachew';
      await c.refreshPreview();
      expect(c.preview.value.geez, 'ሕይወት ገታቸው');
      expect(c.preview.value.approxGeez, isTrue);
      expect(c.preview.value.latin, 'Hiwot Getachew');
    });

    test('inputs are remembered', () async {
      c.father.text = 'Kebede';
      await c.refreshPreview();
      expect(storage.values['full_name.father'], 'Kebede');
    });

    test('grades', () {
      expect(FullNameController.gradeOf(90), SoundGrade.great);
      expect(FullNameController.gradeOf(75), SoundGrade.good);
      expect(FullNameController.gradeOf(55), SoundGrade.ok);
      expect(FullNameController.gradeOf(30), SoundGrade.clash);
    });
  });

  Future<void> pumpApp(WidgetTester t, Widget home) async {
    await t.binding.setSurfaceSize(const Size(390, 1400));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: AppTranslations.english,
        theme: AppTheme.light(AppTranslations.english),
        home: home,
      ),
    );
    await t.runAsync(GoogleFonts.pendingFonts);
  }

  testWidgets('full-name screen renders preview and score', (t) async {
    Get.testMode = true;
    addTearDown(Get.reset);
    final FullNameController c = Get.put(
      FullNameController(
        sampleNames.firstWhere((n) => n.id == 'hana'),
        RepoHarness().repo,
        MemoryStorageService(),
      ),
    );
    await pumpApp(t, const FullNameView());
    await t.enterText(find.byType(TextField).first, 'Tesfaye');
    await t.runAsync(c.refreshPreview);
    await t.pumpAndSettle();
    expect(find.textContaining('Hana Tesfaye'), findsOneWidget);
    expect(find.text('Sound score'.toUpperCase()), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('match animation asset loads; match screen renders', (t) async {
    Get.testMode = true;
    addTearDown(Get.reset);
    final LottieComposition? composition = await t.runAsync(
      () => AssetLottie(AppAssets.matchLottie).load(),
    );
    expect(composition, isNotNull);
    expect(composition!.duration, greaterThan(Duration.zero));

    final PartnerService partner =
        await t.runAsync(
              () => PartnerService(
                FakeRemote(FakeServer(), 'me'),
                MemoryStorageService(),
              ).init(),
            )
            as PartnerService;
    Get.put(
      MatchController(
        NameMatch(nameId: 'hiwot', createdAt: DateTime.utc(2026)),
        RepoHarness().repo,
        partner,
      ),
    );
    await pumpApp(t, const MatchView());
    await t.pump(const Duration(seconds: 3));
    expect(find.text('It’s a match!'), findsOneWidget);
    expect(find.text('Hiwot'), findsOneWidget);
    expect(partner.seenMatchIds, contains('hiwot'));
    expect(t.takeException(), isNull);
  });
}
