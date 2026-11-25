import 'package:flutter_test/flutter_test.dart';
import 'package:habesha_names/app/data/models/gender.dart';
import 'package:habesha_names/app/data/models/name_filter.dart';
import 'package:habesha_names/app/data/models/name_model.dart';
import 'package:habesha_names/app/data/repositories/names_repository.dart';

import '../support/fakes.dart';

void main() {
  late NamesRepository repo;

  setUp(() => repo = RepoHarness().repo);

  Future<Set<String>> ids(NameFilter f) async => {
    for (final NameModel n in await repo.filter(f)) n.id,
  };

  test('empty filter returns everything, most popular first', () async {
    final List<NameModel> all = await repo.filter(NameFilter.none);
    expect(all, hasLength(sampleNames.length));
    expect(all.first.id, 'hiwot'); // popularity 90
    for (int i = 1; i < all.length; i++) {
      expect(all[i - 1].popularity, greaterThanOrEqualTo(all[i].popularity));
    }
  });

  group('gender', () {
    test('single gender', () async {
      expect(await ids(const NameFilter(genders: {Gender.boy})), {
        'abebe',
        'haile',
        'amanuel',
        'gemechu',
      });
    });

    test('several genders (e.g. boy + unisex)', () async {
      expect(
        await ids(const NameFilter(genders: {Gender.boy, Gender.unisex})),
        {'abebe', 'haile', 'amanuel', 'gemechu', 'birhan'},
      );
    });
  });

  group('any-of lists', () {
    test('languages', () async {
      expect(await ids(const NameFilter(languages: {'oromo'})), {
        'hayat',
        'gemechu',
      });
      expect(await ids(const NameFilter(languages: {'oromo', 'tigrinya'})), {
        'hayat',
        'gemechu',
        'hiwot',
        'birhan',
      });
    });

    test('faiths', () async {
      expect(await ids(const NameFilter(faiths: {'catholic'})), {
        'hana',
        'amanuel',
      });
      expect(await ids(const NameFilter(faiths: {'muslim'})), {
        'hayat',
        'nuria',
      });
    });

    test('themes', () async {
      expect(await ids(const NameFilter(themes: {'light'})), {
        'tsehay',
        'birhan',
        'nuria',
      });
    });

    test('stored values are matched case-insensitively', () {
      final NameModel mixedCase = name('x', faiths: ['Muslim']);
      expect(const NameFilter(faiths: {'muslim'}).matches(mixedCase), isTrue);
    });
  });

  group('syllables', () {
    test('exact count', () async {
      expect(await ids(const NameFilter(minSyllables: 4, maxSyllables: 4)), {
        'amanuel',
      });
    });

    test('open-ended ranges', () async {
      expect(await ids(const NameFilter(minSyllables: 3)), {
        'nuria',
        'abebe',
        'abeba',
        'betelhem',
        'amanuel',
        'gemechu',
      });
      final Set<String> short = await ids(const NameFilter(maxSyllables: 2));
      expect(short, isNot(contains('amanuel')));
      expect(short, contains('hiwot'));
    });
  });

  group('first letter', () {
    test('Latin, case-insensitive', () async {
      expect(await ids(const NameFilter(firstLetter: 'h')), {
        'hiwot',
        'hayat',
        'haile',
        'hana',
      });
      expect(await ids(const NameFilter(firstLetter: 'A')), {
        'abebe',
        'abeba',
        'amanuel',
      });
    });

    test(
      "Ge'ez base letter matches every vowel order of that letter",
      () async {
        // አ row: አበበ, አበባ, አማኑኤል
        expect(await ids(const NameFilter(firstLetter: 'አ')), {
          'abebe',
          'abeba',
          'amanuel',
        });
        // ኑሪያ starts with ኑ (2nd order of ነ).
        expect(await ids(const NameFilter(firstLetter: 'ነ')), {'nuria'});
      },
    );

    test("Ge'ez index keeps ሀ and ሐ as separate letters", () async {
      expect(await ids(const NameFilter(firstLetter: 'ሀ')), {'hayat'});
      expect(
        await ids(const NameFilter(firstLetter: 'ሐ')),
        {'hiwot', 'hana'}, // ሕይወት (ሕ is 6th order of ሐ), ሐና
      );
    });

    test('typing a non-first-order letter uses its row', () async {
      expect(await ids(const NameFilter(firstLetter: 'ሕ')), {'hiwot', 'hana'});
    });
  });

  test(
    'easyAbroad: true keeps only easy names; false/null do not filter',
    () async {
      expect(await ids(const NameFilter(easyAbroad: true)), {
        'hiwot',
        'hayat',
        'birhan',
        'nuria',
        'abebe',
        'betelhem',
        'hana',
        'amanuel',
      });
      expect(
        await ids(const NameFilter(easyAbroad: false)),
        hasLength(sampleNames.length),
      );
    },
  );

  test('criteria combine with AND', () async {
    expect(
      await ids(
        const NameFilter(
          genders: {Gender.girl},
          themes: {'light', 'life'},
          easyAbroad: true,
          maxSyllables: 2,
        ),
      ),
      {'hiwot', 'hayat'},
    );
  });

  test('a filter that matches nothing returns an empty list', () async {
    expect(
      await ids(const NameFilter(genders: {Gender.boy}, faiths: {'muslim'})),
      isEmpty,
    );
  });

  group('NameFilter value helpers', () {
    test('isEmpty / activeCount', () {
      expect(NameFilter.none.isEmpty, isTrue);
      expect(const NameFilter(easyAbroad: false).isEmpty, isTrue);
      const NameFilter f = NameFilter(
        genders: {Gender.boy},
        themes: {'faith'},
        minSyllables: 2,
        maxSyllables: 3,
        firstLetter: 'ሀ',
      );
      expect(f.isEmpty, isFalse);
      expect(f.activeCount, 4); // syllable range counts once
    });

    test('copyWith can clear nullable fields', () {
      const NameFilter f = NameFilter(firstLetter: 'A', easyAbroad: true);
      final NameFilter cleared = f.copyWith(
        firstLetter: () => null,
        easyAbroad: () => null,
      );
      expect(cleared.firstLetter, isNull);
      expect(cleared.easyAbroad, isNull);
      expect(f.copyWith(genders: {Gender.girl}).firstLetter, 'A');
    });
  });
}
