import 'package:flutter_test/flutter_test.dart';
import 'package:habesha_names/app/data/models/gender.dart';
import 'package:habesha_names/app/data/models/name_filter.dart';
import 'package:habesha_names/app/data/models/name_model.dart';
import 'package:habesha_names/app/data/models/user_prefs.dart';
import 'package:habesha_names/app/data/repositories/names_repository.dart';

import '../support/fakes.dart';

void main() {
  late NamesRepository repo;
  setUp(() => repo = RepoHarness().repo);

  group('nameOfTheDay', () {
    test('same name all day, different on other days', () async {
      final NameModel? morning = await repo.nameOfTheDay(
        DateTime.utc(2026, 11, 25, 6),
      );
      final NameModel? night = await repo.nameOfTheDay(
        DateTime.utc(2026, 11, 25, 23, 59),
      );
      expect(morning, isNotNull);
      expect(night!.id, morning!.id);

      final Set<String> week = {
        for (int d = 0; d < 7; d++)
          (await repo.nameOfTheDay(DateTime.utc(2026, 11, 1 + d)))!.id,
      };
      expect(week.length, greaterThan(3));
    });

    test(
      'respects the filter, falls back to all names if nothing matches',
      () async {
        for (int d = 1; d <= 10; d++) {
          final NameModel? n = await repo.nameOfTheDay(
            DateTime.utc(2026, 1, d),
            filter: const NameFilter(genders: {Gender.boy}),
          );
          expect(n!.gender, Gender.boy);
        }
        expect(
          await repo.nameOfTheDay(
            DateTime.utc(2026),
            filter: const NameFilter(themes: {'nonexistent'}),
          ),
          isNotNull,
        );
      },
    );
  });

  test('themeGroups: min size, largest first, popularity order', () async {
    final List<ThemeGroup> groups = await repo.themeGroups(minNames: 3);
    expect(groups.map((g) => g.theme), containsAll(['faith', 'light']));
    expect(groups.every((g) => g.names.length >= 3), isTrue);
    for (int i = 1; i < groups.length; i++) {
      expect(
        groups[i - 1].names.length,
        greaterThanOrEqualTo(groups[i].names.length),
      );
    }
    final List<NameModel> faith = groups
        .firstWhere((g) => g.theme == 'faith')
        .names;
    expect(faith.first.id, 'amanuel'); // most popular faith name
  });

  test('getByIds keeps order and skips unknown ids', () async {
    expect((await repo.getByIds(['hana', 'nope', 'abebe'])).map((n) => n.id), [
      'hana',
      'abebe',
    ]);
  });

  group('UserPrefs.toFilter (For you)', () {
    test('expecting a girl → girl + unisex names', () async {
      final List<NameModel> r = await repo.filter(
        const UserPrefs(expecting: Expecting.girl).toFilter(),
      );
      expect(r.map((n) => n.gender).toSet(), {Gender.girl, Gender.unisex});
    });

    test('not sure → every gender', () {
      expect(const UserPrefs().toFilter().isEmpty, isTrue);
    });

    test('chosen faith also includes faith-neutral names', () async {
      final Set<String> ids = {
        for (final NameModel n in await repo.filter(
          const UserPrefs(faiths: {'muslim'}).toFilter(),
        ))
          n.id,
      };
      expect(ids, containsAll(['hayat', 'nuria', 'tsehay', 'birhan']));
      expect(ids, isNot(contains('hana'))); // orthodox/catholic only
    });
  });
}
