import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:habesha_names/app/data/models/gender.dart';
import 'package:habesha_names/app/data/models/name_model.dart';
import 'package:habesha_names/app/data/providers/names_seed_source.dart';

import '../../tools/src/name_csv.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 11, 25);
  const String header =
      'id,name_latin,name_geez,spellings,gender,meaning_en,syllables,'
      'easy_abroad,similar,updated_at';

  group('parseCsv', () {
    test('handles quotes, escaped quotes, commas and newlines in fields', () {
      final List<List<String>> rows = parseCsv(
        '﻿a,b,c\r\n'
        '1,"He blossomed, he flourished","say ""hi""\nthere"\n'
        '\n'
        '2,,last',
      );
      expect(rows, [
        ['a', 'b', 'c'],
        ['1', 'He blossomed, he flourished', 'say "hi"\nthere'],
        ['2', '', 'last'],
      ]);
    });

    test('rejects an unterminated quote', () {
      expect(() => parseCsv('a,"oops\n'), throwsFormatException);
    });
  });

  group('convertRows', () {
    CsvConversion convert(String body, {Map<String, NameModel>? previous}) =>
        convertRows(
          parseCsv('$header\n$body'),
          now: now,
          previous: previous ?? const {},
        );

    test('splits list fields on | and parses types', () {
      final CsvConversion r = convert(
        'hiwot,Hiwot,ሕይወት, Hiwot | Heywet ||Hiywet ,GIRL,Life,2,yes,,',
      );
      expect(r.errors, isEmpty);
      final NameModel n = r.names.single;
      expect(n.spellings, ['Hiwot', 'Heywet', 'Hiywet']);
      expect(n.gender, Gender.girl);
      expect(n.syllables, 2);
      expect(n.easyAbroad, isTrue);
      expect(n.updatedAt, now);
    });

    test('derives id from name_latin when empty', () {
      final CsvConversion r = convert(',Tsion Abebe,ጽዮን,,girl,Zion,2,no,,');
      expect(r.names.single.id, 'tsion-abebe');
    });

    test('reports invalid gender, numbers, booleans and duplicates', () {
      final CsvConversion r = convert(
        'a,A,ሀ,,robot,,1,no,,\n'
        'b,B,ለ,,boy,,two,no,,\n'
        'c,C,ሐ,,boy,,1,maybe,,\n'
        'd,D,መ,,boy,,1,no,,\n'
        'd,D2,ሠ,,boy,,1,no,,\n'
        'e,E,,,boy,,1,no,,',
      );
      expect(r.ok, isFalse);
      expect(
        r.errors.join('\n'),
        allOf(
          contains('invalid gender'),
          contains('not a number'),
          contains('not true/false'),
          contains('duplicate id "d"'),
          contains('name_geez are required'),
        ),
      );
    });

    test('missing required columns is an error', () {
      final CsvConversion r = convertRows(
        parseCsv('id,name_latin\nx,X'),
        now: now,
      );
      expect(r.errors, contains('Missing column "gender"'));
    });

    test('warns about unknown similar ids and unknown columns', () {
      final CsvConversion r = convertRows(
        parseCsv('$header,colour\nx,X,ሀ,,boy,M,1,no,nope,,red'),
        now: now,
      );
      expect(r.ok, isTrue);
      expect(r.warnings, contains('x: similar id "nope" not found'));
      expect(r.warnings, contains('Unknown column "colour" is ignored'));
    });

    test('keeps previous updated_at for unchanged rows only', () {
      final DateTime earlier = DateTime.utc(2026, 1, 1);
      const String row = 'x,X,ሀ,,boy,Meaning,1,no,,';
      final NameModel before = convert(row).names.single;
      final Map<String, NameModel> previous = {
        'x': NameModel.fromJson(
          before.toJson()..['updated_at'] = earlier.toIso8601String(),
        ),
      };

      expect(convert(row, previous: previous).names.single.updatedAt, earlier);
      expect(
        convert(
          'x,X,ሀ,,boy,Changed,1,no,,',
          previous: previous,
        ).names.single.updatedAt,
        now,
      );
    });

    test('explicit updated_at wins', () {
      final CsvConversion r = convert(
        'x,X,ሀ,,boy,M,1,no,,2025-03-04T05:06:07Z',
      );
      expect(r.names.single.updatedAt, DateTime.utc(2025, 3, 4, 5, 6, 7));
    });
  });

  group('bundled assets/data/names.json', () {
    final NamesSeed seed = NamesSeed.fromJsonString(
      File('assets/data/names.json').readAsStringSync(),
    );

    test('parses, has unique ids and valid similar references', () {
      expect(seed.version, greaterThan(0));
      expect(seed.names, isNotEmpty);
      final Set<String> ids = {for (final n in seed.names) n.id};
      expect(ids, hasLength(seed.names.length));
      for (final NameModel n in seed.names) {
        expect(n.nameGeez, isNotEmpty, reason: n.id);
        for (final String s in n.similar) {
          expect(ids, contains(s), reason: '${n.id} → $s');
        }
      }
    });

    test('is in sync with data/names.csv', () {
      final Map<String, dynamic> json =
          jsonDecode(File('assets/data/names.json').readAsStringSync())
              as Map<String, dynamic>;
      final CsvConversion fromCsv = convertRows(
        parseCsv(File('data/names.csv').readAsStringSync()),
        now: now,
        previous: {for (final n in seed.names) n.id: n},
      );
      expect(fromCsv.ok, isTrue, reason: fromCsv.errors.join('\n'));
      expect(
        jsonEncode([for (final n in fromCsv.names) n.toJson()]),
        jsonEncode(json['names']),
        reason: 'Run: dart run tools/csv_to_json.dart',
      );
    });
  });
}
