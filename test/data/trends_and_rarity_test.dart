import 'package:flutter_test/flutter_test.dart';
import 'package:habesha_names/app/data/models/gender.dart';
import 'package:habesha_names/app/data/models/name_filter.dart';
import 'package:habesha_names/app/data/models/name_model.dart';
import 'package:habesha_names/app/data/models/rarity.dart';
import 'package:habesha_names/app/data/repositories/names_repository.dart';

import '../support/fakes.dart';

NameModel n(
  String id, {
  bool modern = false,
  Rarity rarity = Rarity.unique,
  int trend = 0,
  int popularity = 50,
  Gender gender = Gender.girl,
}) => NameModel(
  id: id,
  nameLatin: id,
  nameGeez: 'ስ',
  gender: gender,
  updatedAt: t0,
  modern: modern,
  rarity: rarity,
  trendScore: trend,
  popularity: popularity,
);

void main() {
  group('RarityRanker (same rule as functions/src/trends.ts)', () {
    test('top 10% popular, bottom 50% rare, rest unique', () {
      final List<String> ids = [for (int i = 0; i < 20; i++) 'n$i'];
      final Map<String, Rarity> r = RarityRanker.rank(
        ids,
        trend: (id) => 100 - int.parse(id.substring(1)),
        popularity: (_) => 0,
      );
      int count(Rarity x) => r.values.where((v) => v == x).length;
      expect(count(Rarity.popular), 2);
      expect(count(Rarity.rare), 10);
      expect(count(Rarity.unique), 8);
      expect(r['n0'], Rarity.popular);
      expect(r['n19'], Rarity.rare);
    });

    test('ties on trend fall back to popularity', () {
      final Map<String, Rarity> r = RarityRanker.rank(
        ['a', 'b'],
        trend: (_) => 0,
        popularity: (id) => id == 'b' ? 90 : 10,
      );
      expect(r, {'b': Rarity.popular, 'a': Rarity.rare});
    });
  });

  test('NameModel JSON round-trips the new fields', () {
    final NameModel m = n('x', modern: true, rarity: Rarity.rare, trend: 7);
    final NameModel back = NameModel.fromJson(m.toJson());
    expect(back.modern, isTrue);
    expect(back.rarity, Rarity.rare);
    expect(back.trendScore, 7);
    // Old documents without the fields still parse.
    final NameModel legacy = NameModel.fromJson(
      m.toJson()
        ..remove('modern')
        ..remove('rarity')
        ..remove('trend_score'),
    );
    expect(legacy.rarity, Rarity.unique);
    expect(legacy.modern, isFalse);
  });

  test('NameFilter: modern and rarities', () {
    final List<NameModel> all = [
      n('a', modern: true, rarity: Rarity.rare),
      n('b', rarity: Rarity.rare),
      n('c', modern: true, rarity: Rarity.popular),
    ];
    Set<String> ids(NameFilter f) => {for (final x in f.apply(all)) x.id};
    expect(ids(const NameFilter(modern: true)), {'a', 'c'});
    expect(ids(const NameFilter(rarities: {Rarity.rare})), {'a', 'b'});
    expect(ids(const NameFilter(modern: true, rarities: {Rarity.rare})), {'a'});
    expect(const NameFilter(modern: true).activeCount, 1);
    expect(const NameFilter(modern: false).isEmpty, isTrue);
  });

  test('trending: trendScore > 0 only, highest first', () async {
    final RepoHarness h = RepoHarness(
      seed: [
        n('quiet'),
        n('hot', trend: 9),
        n('warm', trend: 3),
        n('warm2', trend: 3, popularity: 99),
      ],
    );
    final NamesRepository repo = h.repo;
    expect((await repo.trending()).map((x) => x.id), ['hot', 'warm2', 'warm']);
    expect(await repo.trending(limit: 1), hasLength(1));
  });
}
