import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habesha_names/app/data/models/ai_feature.dart';
import 'package:habesha_names/app/modules/discover/controllers/ai_waitlist_controller.dart';
import 'package:habesha_names/app/modules/studio/controllers/studio_controller.dart';
import 'package:habesha_names/app/modules/studio/views/studio_view.dart';
import 'package:habesha_names/app/services/ai_waitlist_service.dart';
import 'package:habesha_names/app/theme/app_theme.dart';
import 'package:habesha_names/app/translations/app_translations.dart';
import 'package:habesha_names/app/translations/locale_keys.dart';

import '../support/memory_storage.dart';
import 'ai_waitlist_test.dart' show FakeWaitlistRemote;

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  Future<(StudioController, AiWaitlistController, FakeWaitlistRemote)> pump(
    WidgetTester t, {
    Locale locale = AppTranslations.english,
    bool dark = false,
  }) async {
    Get.testMode = true;
    addTearDown(Get.reset);
    final FakeWaitlistRemote remote = FakeWaitlistRemote();
    final AiWaitlistService service = AiWaitlistService(
      remote,
      MemoryStorageService(),
    );
    final AiWaitlistController waitlist = Get.put(
      AiWaitlistController(service),
    );
    final StudioController studio = Get.put(StudioController(waitlist));
    t.view.physicalSize = const Size(360, 640); // 5-inch phone
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: locale,
        theme: dark ? AppTheme.dark(locale) : AppTheme.light(locale),
        home: const Scaffold(body: StudioView()),
      ),
    );
    await t.runAsync(GoogleFonts.pendingFonts);
    await t.pumpAndSettle();
    return (studio, waitlist, remote);
  }

  testWidgets('name finder → Coming soon → waitlist prefilled with the wish', (
    t,
  ) async {
    final (StudioController s, AiWaitlistController w, _) = await pump(t);
    expect(find.text(LocaleKeys.studioComingSoon.tr), findsWidgets);

    await t.tap(find.text(LocaleKeys.studioStyleModern.tr));
    await t.enterText(find.byType(TextField), 'Short name meaning light');
    await t.ensureVisible(find.text(LocaleKeys.studioFind.tr));
    await t.pumpAndSettle();
    await t.tap(find.text(LocaleKeys.studioFind.tr));
    await t.pump();
    await t.pump(const Duration(milliseconds: 600)); // sheet icon pulses

    expect(s.styles, {StudioStyle.modern});
    expect(
      find.textContaining(LocaleKeys.aiFeatureNameFinder.tr),
      findsWidgets,
    );
    expect(w.chosen, {AiFeature.nameFinder});
    expect(w.text.text, 'Short name meaning light');
    expect(find.text(LocaleKeys.aiNotifyMe.tr), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('face preview photo slot and button both say Coming soon', (
    t,
  ) async {
    final (StudioController s, AiWaitlistController w, _) = await pump(t);
    await t.scrollUntilVisible(
      find.text(LocaleKeys.studioParentA.tr),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await t.pumpAndSettle();
    await t.tap(find.text(LocaleKeys.studioParentA.tr));
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    expect(s.soonFeature.value, AiFeature.facePreview);
    expect(w.chosen, {AiFeature.facePreview});
    expect(t.takeException(), isNull);
  });

  testWidgets('fits a 5-inch screen in Amharic dark mode', (t) async {
    await pump(t, locale: AppTranslations.amharic, dark: true);
    await t.scrollUntilVisible(
      find.text(LocaleKeys.studioPreview.tr),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(t.takeException(), isNull);
  });
}
