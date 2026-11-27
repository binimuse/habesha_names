import 'package:flutter_test/flutter_test.dart';
import 'package:habesha_names_admin/core/csv_import.dart';
import 'package:habesha_names_admin/data/admin_name.dart';

const String header =
    'id,name_latin,name_geez,gender,languages,faiths,meaning_en,themes,'
    'syllables,easy_abroad,similar';

void main() {
  const AdminName hiwot = AdminName(
    id: 'hiwot',
    nameLatin: 'Hiwot',
    nameGeez: 'ሕይወት',
    gender: 'girl',
    spellings: ['Hiwot'],
    languages: ['amharic'],
    faiths: ['orthodox'],
    themes: ['life'],
    meaningEn: 'Life',
    syllables: 2,
  );

  test('parses quoted CSV and Excel (tab) pastes', () {
    expect(parseDelimited('a,"b, c","d ""q"""\n1,2,3\n'), [
      ['a', 'b, c', 'd "q"'],
      ['1', '2', '3'],
    ]);
    expect(parseDelimited('a\tb, c\r\n1\t2\r\n\r\n'), [
      ['a', 'b, c'],
      ['1', '2'],
    ]);
  });

  test('add / update / unchanged against existing names', () {
    final ImportPreview p = previewImport(
      '$header\n'
      'hiwot,Hiwot,ሕይወት,girl,amharic,orthodox,Life,life,2,false,\n'
      ',Selam Tesfa,ሰላም,F,amharic|tigrinya,neutral,Peace,peace,2,yes,hiwot\n'
      'hana,Hana,ሐና,girl,amharic,orthodox,Grace,,2,false,\n',
      existing: {
        'hiwot': hiwot,
        'hana': const AdminName(
          id: 'hana',
          nameLatin: 'Hana',
          nameGeez: 'ሃና',
          gender: 'girl',
        ),
      },
    );
    expect(p.errors, isEmpty);
    expect(p.count(ImportAction.unchanged), 1);
    expect(p.count(ImportAction.add), 1);
    expect(p.count(ImportAction.update), 1);
    final AdminName selam = p.rows[1].name;
    expect(selam.id, 'selam-tesfa');
    expect(selam.gender, 'girl');
    expect(selam.languages, ['amharic', 'tigrinya']);
    expect(selam.easyAbroad, isTrue);
    expect(p.toWrite.map((n) => n.id), ['selam-tesfa', 'hana']);
  });

  test('reports row errors with line numbers and skips those rows', () {
    final ImportPreview p = previewImport(
      '$header\n'
      'x,X,abc,girl,amharic,neutral,,,2,false,\n'
      'y,Y,ዮ,alien,amharic,neutral,,,2,false,\n'
      'z,Z,ዘ,boy,klingon,neutral,,,99,maybe,\n'
      'ok,Ok,ኦ,boy,,,,,,,\n',
      existing: const {},
    );
    expect(p.rows.map((r) => r.name.id), ['ok']);
    expect(p.rows.single.name.faiths, ['neutral']); // defaults
    expect(p.errors.join('\n'), contains('Line 2: name_geez "abc"'));
    expect(p.errors.join('\n'), contains('Line 3: gender "alien"'));
    expect(p.errors.join('\n'), contains('unknown languages "klingon"'));
    expect(p.errors.join('\n'), contains('syllables "99"'));
    expect(p.errors.join('\n'), contains('easy_abroad "maybe"'));
  });

  test('missing columns, existing ids without updates, bad similar ids', () {
    expect(
      previewImport('name_latin,gender\nA,boy', existing: const {}).errors,
      ['Missing column "name_geez"'],
    );
    final ImportPreview p = previewImport(
      '$header\nhiwot,Hiwot,ሕይወት,girl,,,,,,,nobody\n',
      existing: {'hiwot': hiwot},
      allowUpdates: false,
    );
    expect(p.rows, isEmpty); // existing name is skipped, never overwritten
    expect(p.errors, isEmpty);
    expect(p.warnings.join(), contains('already exists — skipped'));
  });

  test("warns when a new id has the same Ge'ez as another name", () {
    final ImportPreview p = previewImport(
      '$header\n'
      'hiwet,Hiwet,ሕይወት,girl,,,,,,,\n'
      'mimi,Mimi,ሚሚ,girl,,,,,,,\n'
      'mimy,Mimy,ሚሚ,girl,,,,,,,\n',
      existing: {'hiwot': hiwot},
    );
    expect(p.errors, isEmpty);
    expect(p.count(ImportAction.add), 3); // warned, not blocked
    final String w = p.warnings.join('\n');
    expect(w, contains('"hiwet" has the same Ge\'ez (ሕይወት) as "hiwot"'));
    expect(w, contains('"mimy" has the same Ge\'ez (ሚሚ) as "mimi"'));
  });
}
