import 'package:flutter_test/flutter_test.dart';
import 'package:habesha_names/app/data/models/gender.dart';
import 'package:habesha_names/app/data/models/name_filter.dart';
import 'package:habesha_names/app/data/models/name_model.dart';
import 'package:habesha_names/app/data/repositories/names_repository.dart';

import '../support/fakes.dart';

void main() {
  late NamesRepository repo;

  setUp(() => repo = RepoHarness().repo);

  Future<List<String>> ids(String query, {NameFilter? filter}) async => [
    for (final NameModel n in await repo.search(query, filter: filter)) n.id,
  ];

  Future<String?> top(String query) async {
    final List<String> r = await ids(query);
    return r.isEmpty ? null : r.first;
  }

  group('Latin spellings', () {
    test('listed spellings and unlisted variants find the same name', () async {
      for (final String q in ['Hiwot', 'heywet', 'HIYWET', 'hiwet', 'Hywot']) {
        expect(await top(q), 'hiwot', reason: q);
      }
    });

    test('ai/ay, ts/tz and doubled letters fold', () async {
      expect(await top('Hayle'), 'haile');
      expect(await top('Tzehay'), 'tsehay');
      expect(await top('Hannah'), 'hana');
      expect(await top('hanaa'), 'hana');
    });

    test('accents and case are ignored', () async {
      expect(await top('HAILÉ'), 'haile');
      expect(await top('  amanuel  '), 'amanuel');
    });

    test('a / e swaps match through the consonant skeleton', () async {
      expect(await top('Birhen'), 'birhan');
      expect(await top('Abiba'), anyOf('abeba', 'abebe'));
    });

    test('prefix (as-you-type) matches', () async {
      expect(await top('hiw'), 'hiwot');
      expect(await top('Bethl'), 'betelhem');
      expect(await ids('tse'), contains('tsehay'));
    });
  });

  group("Ge'ez", () {
    test('exact Ge\'ez finds the name', () async {
      expect(await top('ሕይወት'), 'hiwot');
      expect(await top('ፀሐይ'), 'tsehay');
      expect(await top('ኃይሌ'), 'haile');
    });

    test('other vowel orders / homophone letters still match', () async {
      expect(await top('ህይወት'), 'hiwot'); // ሕ (6th of ሐ) → ህ (6th of ሀ)
      expect(await top('ሂወት'), 'hiwot'); // different vowel order, no ይ
      expect(await top('ጸሀይ'), 'tsehay'); // ፀ → ጸ, ሐ → ሀ
      expect(await top('ሀና'), 'hana'); // ሐ → ሀ
      expect(await top('ሀይሌ'), 'haile'); // ኃ → ሀ-row
    });

    test('Ge\'ez prefix matches while typing', () async {
      expect(await top('ሕይ'), 'hiwot');
      expect(await top('ቤተል'), 'betelhem');
    });

    test('cross-script: Ge\'ez query ↔ Latin spelling', () async {
      expect(await top('ብርሃን'), 'birhan');
      expect(await top('አማኑኤል'), 'amanuel');
    });
  });

  group('ranking', () {
    test('exact match beats a more popular near match', () async {
      // Abeba is more popular, but the user typed Abebe exactly.
      final List<String> r = await ids('abebe');
      expect(r.first, 'abebe');
      expect(r, contains('abeba'));
    });

    test('equally good matches are ordered by popularity', () async {
      final List<String> r = await ids('ha');
      expect(r.indexOf('hana'), lessThan(r.indexOf('haile')));
    });

    test('names outrank meaning-only matches', () async {
      // "ብርሃን" is Birhan's name and Nuria's Amharic meaning.
      expect(await ids('ብርሃን'), ['birhan', 'nuria']);
    });
  });

  group('nicknames and meanings', () {
    test('nickname finds the full name', () async {
      expect(await top('Beti'), 'betelhem');
      expect(await top('hiwi'), 'hiwot');
    });

    test('English meaning words find names', () async {
      expect(await ids('light'), containsAll(['birhan', 'nuria']));
      expect(await ids('grace'), ['hana']);
    });

    test('very short queries do not match inside meanings', () async {
      expect(await ids('li'), isNot(contains('birhan')));
    });
  });

  group('edge cases', () {
    test('blank or punctuation-only query returns nothing', () async {
      expect(await ids(''), isEmpty);
      expect(await ids('   '), isEmpty);
      expect(await ids('።'), isEmpty);
    });

    test('unknown query returns nothing', () async {
      expect(await ids('xyzzy'), isEmpty);
    });

    test('search can be combined with a filter', () async {
      final List<String> r = await ids(
        'light',
        filter: const NameFilter(faiths: {'muslim'}),
      );
      expect(r, ['nuria']);
    });

    test('filter on search keeps search ranking', () async {
      final List<String> r = await ids(
        'ha',
        filter: const NameFilter(genders: {Gender.girl}),
      );
      expect(r, isNot(contains('haile')));
      expect(r.first, 'hana');
    });
  });
}
