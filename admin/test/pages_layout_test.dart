import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:habesha_names_admin/core/theme.dart';
import 'package:habesha_names_admin/data/admin_name.dart';
import 'package:habesha_names_admin/data/admin_repository.dart';
import 'package:habesha_names_admin/core/csv_import.dart';
import 'package:habesha_names_admin/pages/import_page.dart';
import 'package:habesha_names_admin/pages/names_page.dart';

class FakeRepo implements AdminRepository {
  final List<AdminName> names = const [
    AdminName(
      id: 'hiwot',
      nameLatin: 'Hiwot',
      nameGeez: 'ሕይወት',
      gender: 'girl',
      meaningEn: 'Life',
      verified: true,
      audioUrl: 'https://x/a.mp3',
    ),
    AdminName(
      id: 'abebe',
      nameLatin: 'Abebe',
      nameGeez: 'አበበ',
      gender: 'boy',
      deleted: true,
    ),
  ];
  List<AdminName> imported = [];

  final List<AdminName> drafts = const [
    AdminName(id: 'selam', nameLatin: 'Selam', nameGeez: 'ሰላም', gender: 'girl'),
  ];
  bool? importedAsDrafts;

  @override
  Stream<List<AdminName>> watchNames() => Stream.value(names);

  @override
  Stream<List<AdminName>> watchDrafts() => Stream.value(drafts);

  @override
  Future<void> importNames(
    List<AdminName> n, {
    bool asDrafts = true,
    void Function(int)? onProgress,
  }) async {
    imported = n;
    importedAsDrafts = asDrafts;
    onProgress?.call(n.length);
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Future<void> pumpPage(WidgetTester t, Size size, Widget page) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(GetMaterialApp(theme: AdminTheme.light(), home: page));
  await t.pumpAndSettle();
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  for (final Size size in const [Size(1280, 800), Size(390, 844)]) {
    testWidgets('names page at $size', (t) async {
      final FakeRepo repo = FakeRepo();
      Get.put<AdminRepository>(repo);
      await pumpPage(t, size, const NamesPage());
      expect(find.textContaining('Hiwot'), findsOneWidget);
      expect(find.text('Published'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget); // Selam, draft only
      expect(find.textContaining('Abebe'), findsNothing); // deleted hidden
      final NamesController c = Get.find();
      expect(c.liveCount, 1);
      expect(c.unpublished.map((n) => n.id), ['selam']);
      c.status.value = StatusFilter.deleted;
      await t.pumpAndSettle();
      expect(find.textContaining('Abebe'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('import page check + import at $size', (t) async {
      final FakeRepo repo = FakeRepo();
      final NamesController names = Get.put(NamesController(repo));
      await Future<void>.value();
      final ImportController c = Get.put(ImportController(repo, names));
      await pumpPage(t, size, const ImportPage());
      c.input.text =
          'name_latin\tname_geez\tgender\tmeaning_en\n'
          'Selam\tሰላም\tgirl\tPeace\n'
          'Hiwot\tሕይወት\tgirl\tLife\n';
      await t.tap(find.text('Check'));
      await t.pumpAndSettle();
      expect(c.preview.value!.errors, isEmpty);
      // Selam is already a draft and Hiwot is live → both are updates.
      expect(c.preview.value!.count(ImportAction.update), 2);
      await t.drag(find.byType(ListView).first, const Offset(0, -600));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      unawaited(c.runImport());
      await t.pumpAndSettle();
      expect(repo.imported.map((n) => n.id), ['selam', 'hiwot']);
      expect(c.result.value, contains('Imported 2 names'));
      expect(repo.importedAsDrafts, isTrue); // default: drafts
    });
  }
}
