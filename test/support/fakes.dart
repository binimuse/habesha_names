import 'package:habesha_names/app/data/models/gender.dart';
import 'package:habesha_names/app/data/models/name_model.dart';
import 'package:habesha_names/app/data/providers/names_local_source.dart';
import 'package:habesha_names/app/data/providers/names_remote_source.dart';
import 'package:habesha_names/app/data/providers/names_seed_source.dart';
import 'package:habesha_names/app/data/providers/names_sync_state.dart';
import 'package:habesha_names/app/data/repositories/names_repository.dart';

final DateTime t0 = DateTime.utc(2026, 1, 1);

NameModel name(
  String id, {
  String? latin,
  String geez = 'ስም',
  List<String> spellings = const [],
  Gender gender = Gender.girl,
  List<String> languages = const ['amharic'],
  List<String> faiths = const ['neutral'],
  List<String> themes = const [],
  String meaningEn = '',
  String meaningAm = '',
  List<String> nicknames = const [],
  List<String> similar = const [],
  int syllables = 2,
  bool easyAbroad = false,
  int popularity = 50,
  DateTime? updatedAt,
}) {
  return NameModel(
    id: id,
    nameLatin: latin ?? id[0].toUpperCase() + id.substring(1),
    nameGeez: geez,
    spellings: spellings,
    gender: gender,
    languages: languages,
    faiths: faiths,
    themes: themes,
    meaningEn: meaningEn,
    meaningAm: meaningAm,
    nicknames: nicknames,
    similar: similar,
    syllables: syllables,
    easyAbroad: easyAbroad,
    popularity: popularity,
    updatedAt: updatedAt ?? t0,
  );
}

/// A small, controlled catalogue covering the tricky cases.
final List<NameModel> sampleNames = [
  name(
    'hiwot',
    geez: 'ሕይወት',
    spellings: ['Heywet', 'Hiywet'],
    themes: ['life'],
    meaningEn: 'Life',
    meaningAm: 'ሕይወት',
    languages: ['amharic', 'tigrinya'],
    nicknames: ['Hiwi'],
    similar: ['hayat'],
    easyAbroad: true,
    popularity: 90,
  ),
  name(
    'hayat',
    geez: 'ሀያት',
    themes: ['life'],
    meaningEn: 'Life',
    faiths: ['muslim'],
    languages: ['amharic', 'oromo'],
    syllables: 2,
    easyAbroad: true,
    popularity: 76,
  ),
  name(
    'tsehay',
    geez: 'ፀሐይ',
    spellings: ['Tsehaye', 'Tsahay'],
    themes: ['nature', 'light'],
    meaningEn: 'Sun',
    meaningAm: 'ፀሐይ',
    popularity: 62,
  ),
  name(
    'birhan',
    geez: 'ብርሃን',
    spellings: ['Berhan', 'Brhan'],
    gender: Gender.unisex,
    themes: ['light'],
    meaningEn: 'Light',
    meaningAm: 'ብርሃን',
    languages: ['amharic', 'tigrinya'],
    easyAbroad: true,
    popularity: 66,
  ),
  name(
    'nuria',
    geez: 'ኑሪያ',
    spellings: ['Nuriya'],
    themes: ['light'],
    meaningEn: 'Light',
    meaningAm: 'ብርሃን',
    faiths: ['muslim'],
    syllables: 3,
    easyAbroad: true,
    popularity: 70,
  ),
  name(
    'abebe',
    geez: 'አበበ',
    gender: Gender.boy,
    themes: ['nature'],
    meaningEn: 'He blossomed',
    syllables: 3,
    easyAbroad: true,
    popularity: 40,
  ),
  name(
    'abeba',
    geez: 'አበባ',
    themes: ['nature'],
    meaningEn: 'Flower',
    syllables: 3,
    popularity: 80,
  ),
  name(
    'betelhem',
    geez: 'ቤተልሔም',
    spellings: ['Bethlehem'],
    faiths: ['orthodox', 'protestant'],
    themes: ['faith'],
    nicknames: ['Beti', 'Betty'],
    syllables: 3,
    easyAbroad: true,
    popularity: 82,
  ),
  name(
    'haile',
    geez: 'ኃይሌ',
    spellings: ['Hayle'],
    gender: Gender.boy,
    themes: ['strength'],
    meaningEn: 'My power',
    popularity: 70,
  ),
  name(
    'hana',
    geez: 'ሐና',
    spellings: ['Hanna', 'Hannah'],
    faiths: ['orthodox', 'catholic'],
    themes: ['faith'],
    meaningEn: 'Grace',
    easyAbroad: true,
    popularity: 83,
  ),
  name(
    'amanuel',
    geez: 'አማኑኤል',
    spellings: ['Emmanuel'],
    gender: Gender.boy,
    faiths: ['orthodox', 'protestant', 'catholic'],
    themes: ['faith'],
    meaningEn: 'God is with us',
    syllables: 4,
    easyAbroad: true,
    popularity: 88,
  ),
  name(
    'gemechu',
    geez: 'ገመቹ',
    gender: Gender.boy,
    languages: ['oromo'],
    themes: ['joy'],
    meaningEn: 'Joy',
    syllables: 3,
    popularity: 58,
  ),
];

class InMemoryLocalSource implements NamesLocalSource {
  final Map<String, NameModel> rows = {};
  int upsertCalls = 0;

  @override
  Future<int> count() async => rows.length;

  @override
  Future<List<NameModel>> getAll() async => rows.values.toList();

  @override
  Future<void> upsertAll(List<NameModel> names) async {
    upsertCalls++;
    for (final NameModel n in names) {
      rows[n.id] = n;
    }
  }

  @override
  Future<void> deleteByIds(List<String> ids) async => ids.forEach(rows.remove);
}

class FakeSeedSource implements NamesSeedSource {
  FakeSeedSource(this.names, {this.version = 1});

  List<NameModel> names;
  int version;
  int loads = 0;

  /// Thrown (once) by the next [load].
  Object? failNext;

  @override
  Future<NamesSeed> load() async {
    loads++;
    final Object? error = failNext;
    failNext = null;
    if (error != null) throw error;
    return NamesSeed(version: version, names: names);
  }
}

class FakeRemoteSource implements NamesRemoteSource {
  FakeRemoteSource({this.isAvailable = true});

  @override
  bool isAvailable;

  RemoteNameChanges next = RemoteNameChanges.empty;
  Object? error;
  final List<DateTime?> requestedSince = [];

  @override
  Future<RemoteNameChanges> fetchChangedSince(DateTime? since) async {
    requestedSince.add(since);
    await Future<void>.delayed(Duration.zero);
    if (error != null) throw error!;
    return next;
  }
}

class MemorySyncState implements NamesSyncState {
  @override
  DateTime? lastSyncedAt;

  @override
  int seedVersion = 0;

  @override
  Future<void> setLastSyncedAt(DateTime value) async => lastSyncedAt = value;

  @override
  Future<void> setSeedVersion(int value) async => seedVersion = value;
}

/// Repository wired with in-memory fakes.
class RepoHarness {
  RepoHarness({List<NameModel>? seed, int seedVersion = 1, bool remote = true})
    : local = InMemoryLocalSource(),
      seed = FakeSeedSource(seed ?? sampleNames, version: seedVersion),
      remote = FakeRemoteSource(isAvailable: remote),
      syncState = MemorySyncState() {
    repo = build();
  }

  final InMemoryLocalSource local;
  final FakeSeedSource seed;
  final FakeRemoteSource remote;
  final MemorySyncState syncState;
  late NamesRepository repo;

  /// A fresh repository over the same storage (simulates an app restart).
  NamesRepository build() => NamesRepository(
    local: local,
    seed: seed,
    remote: remote,
    syncState: syncState,
  );
}
