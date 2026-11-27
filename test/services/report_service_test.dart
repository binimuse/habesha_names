import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habesha_names/app/modules/name_detail/widgets/report_sheet.dart';
import 'package:habesha_names/app/services/report_service.dart';
import 'package:habesha_names/app/theme/app_theme.dart';
import 'package:habesha_names/app/translations/app_translations.dart';
import 'package:habesha_names/app/translations/locale_keys.dart';

import '../support/fakes.dart';

class FakeReportRemote implements ReportRemote {
  @override
  bool isAvailable = true;
  final List<Map<String, Object>> sent = [];

  @override
  Future<String?> ensureUid() async => 'u1';

  @override
  Future<void> add(Map<String, Object> data) async => sent.add(data);
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  test('writes a report with a snapshot of the name', () async {
    final FakeReportRemote remote = FakeReportRemote();
    final ReportService s = ReportService(remote);
    await s.submit(
      sampleNames.first,
      fields: {ReportField.origin, ReportField.meaning},
      message: '  The meaning is "Life itself"  ',
      language: 'am',
    );
    final Map<String, Object> r = remote.sent.single;
    expect(r['uid'], 'u1');
    expect(r['name_id'], sampleNames.first.id);
    expect(r['name_geez'], sampleNames.first.nameGeez);
    expect(r['fields'], ['meaning', 'origin']); // stable order
    expect(r['message'], 'The meaning is "Life itself"');
    expect(r['language'], 'am');
    expect(r['status'], 'open');
  });

  test('needs a field and a note; reports offline', () async {
    final FakeReportRemote remote = FakeReportRemote();
    final ReportService s = ReportService(remote);
    Future<void> send(Set<ReportField> f, String m) =>
        s.submit(sampleNames.first, fields: f, message: m, language: 'en');

    await expectLater(
      send({}, 'wrong meaning'),
      throwsA(isA<ReportException>()),
    );
    await expectLater(
      send({ReportField.meaning}, ' a '),
      throwsA(isA<ReportException>()),
    );
    remote.isAvailable = false;
    await expectLater(
      send({ReportField.meaning}, 'wrong meaning'),
      throwsA(
        isA<ReportException>().having((e) => e.reason, 'r', 'unavailable'),
      ),
    );
    expect(remote.sent, isEmpty);
    expect(ReportField.values.map((f) => f.code), [
      'meaning',
      'geez',
      'spelling',
      'pronunciation',
      'gender',
      'origin',
      'other',
    ]);
  });

  testWidgets('sheet fits a 5-inch screen in Amharic dark mode and sends', (
    t,
  ) async {
    Get.testMode = true;
    addTearDown(Get.reset);
    final FakeReportRemote remote = FakeReportRemote();
    Get.put(ReportService(remote));
    t.view.physicalSize = const Size(360, 640);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: AppTranslations.amharic,
        theme: AppTheme.dark(AppTranslations.amharic),
        home: Scaffold(body: ReportSheet(name: sampleNames.first)),
      ),
    );
    await t.runAsync(GoogleFonts.pendingFonts);
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);

    await t.tap(find.text(LocaleKeys.reportSend.tr));
    await t.pumpAndSettle();
    expect(find.text(LocaleKeys.reportNeedInput.tr), findsOneWidget);

    await t.tap(find.text(LocaleKeys.reportFieldMeaning.tr));
    await t.enterText(find.byType(TextField), 'ትርጉሙ ሌላ ነው');
    await t.tap(find.text(LocaleKeys.reportSend.tr));
    await t.pumpAndSettle();
    expect(remote.sent.single['fields'], ['meaning']);
    expect(find.text(LocaleKeys.reportThanks.tr), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
