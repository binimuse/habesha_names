import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:habesha_names_admin/core/theme.dart';
import 'package:habesha_names_admin/data/admin_name.dart';
import 'package:habesha_names_admin/data/admin_repository.dart';
import 'package:habesha_names_admin/pages/name_edit_page.dart';

class FakeRepo implements AdminRepository {
  @override
  Future<NameEntry?> getEntry(String id) async => const NameEntry(
    published: AdminName(
      id: 'hiwot',
      nameLatin: 'Hiwot',
      nameGeez: 'ሕይወት',
      gender: 'girl',
      languages: ['amharic'],
      faiths: ['orthodox'],
      themes: ['life'],
      meaningEn: 'Life',
      rarity: 'popular',
    ),
  );

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  for (final Size size in const [
    Size(1440, 900),
    Size(1024, 768),
    Size(800, 900),
    Size(390, 844),
  ]) {
    for (final bool isNew in [true, false]) {
      testWidgets('edit page ${isNew ? 'new' : 'existing'} at $size', (
        t,
      ) async {
        Get.testMode = true;
        addTearDown(Get.reset);
        t.view.physicalSize = size;
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        Get.put(
          NameEditController(
            FakeRepo(),
            isNew ? null : const NameEditArgs(id: 'hiwot'),
          ),
        );
        await t.pumpWidget(
          GetMaterialApp(theme: AdminTheme.light(), home: const NameEditPage()),
        );
        await t.pumpAndSettle();
        // Scroll through the whole form so every section lays out.
        for (int i = 0; i < 8; i++) {
          await t.drag(find.byType(ListView), const Offset(0, -500));
          await t.pumpAndSettle();
        }
        expect(t.takeException(), isNull);
      });
    }
  }
}
