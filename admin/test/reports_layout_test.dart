import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:habesha_names_admin/core/theme.dart';
import 'package:habesha_names_admin/data/admin_name.dart';
import 'package:habesha_names_admin/data/admin_repository.dart';
import 'package:habesha_names_admin/pages/name_edit_page.dart';
import 'package:habesha_names_admin/pages/reports_page.dart';

final NameReport report = NameReport(
  id: 'r1',
  nameId: 'hiwot',
  nameLatin: 'Hiwot',
  nameGeez: 'ሕይወት',
  fields: const ['meaning', 'origin', 'pronunciation'],
  message: 'The meaning should be "Life" and the origin Ge\'ez, not Amharic.',
  language: 'am',
  status: 'open',
  createdAt: DateTime.utc(2026, 11, 26, 9),
);

class FakeRepo implements AdminRepository {
  final List<(String, String)> statusCalls = [];
  AdminName? published;

  @override
  Stream<List<NameReport>> watchReports() => Stream.value([
    report,
    NameReport(
      id: 'r2',
      nameId: 'selam',
      nameLatin: 'Selam',
      nameGeez: 'ሰላም',
      fields: const ['other'],
      message: 'ok',
      language: 'en',
      status: 'resolved',
    ),
  ]);

  @override
  Future<NameEntry?> getEntry(String id) async => const NameEntry(
    published: AdminName(
      id: 'hiwot',
      nameLatin: 'Hiwot',
      nameGeez: 'ሕይወት',
      gender: 'girl',
      languages: ['amharic'],
      faiths: ['neutral'],
      meaningEn: 'Light',
    ),
  );

  @override
  Future<void> setReportStatus(String id, String status) async =>
      statusCalls.add((id, status));

  @override
  Future<void> publish(AdminName n) async => published = n;

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Future<void> pumpAt(WidgetTester t, Size size, Widget home) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(GetMaterialApp(theme: AdminTheme.light(), home: home));
  await t.pumpAndSettle();
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  for (final Size size in const [Size(1280, 800), Size(390, 844)]) {
    testWidgets('reports tab at $size: open by default, filters', (t) async {
      Get.put<AdminRepository>(FakeRepo());
      await pumpAt(t, size, const ReportsPage());
      expect(find.textContaining('Hiwot'), findsOneWidget);
      expect(find.textContaining('Selam'), findsNothing); // resolved hidden
      await t.tap(find.text('All'));
      await t.pumpAndSettle();
      expect(find.textContaining('Selam'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('editor pins the report and resolves it on publish at $size', (
      t,
    ) async {
      final FakeRepo repo = FakeRepo();
      final NameEditController c = Get.put(
        NameEditController(repo, NameEditArgs(id: 'hiwot', report: report)),
      );
      await pumpAt(t, size, const NameEditPage());
      expect(find.text('User report'), findsOneWidget);
      expect(find.textContaining('The meaning should be'), findsOneWidget);
      expect(t.takeException(), isNull);

      c.meaningEn.text = 'Life';
      await c.publish();
      await t.pumpAndSettle();
      expect(repo.published!.meaningEn, 'Life');
      expect(repo.statusCalls, [('r1', 'resolved')]);
      await t.pump(const Duration(seconds: 5)); // let the snackbar finish
      await t.pumpAndSettle();
    });
  }
}
