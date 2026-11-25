import 'dart:async';

import '../../services/crash_reporter.dart';
import '../models/name_filter.dart';
import '../models/name_model.dart';
import '../models/sync_result.dart';
import '../providers/names_local_source.dart';
import '../providers/names_remote_source.dart';
import '../providers/names_seed_source.dart';
import '../providers/names_sync_state.dart';
import '../search/name_search_index.dart';
import '../search/similar_names.dart';

/// Single entry point for name data.
///
/// Local-first: names come from the on-device DB (seeded from the bundled
/// `names.json` on first launch) and are held in memory for instant search
/// and filtering. [syncFromFirestore] pulls only names changed since the
/// last sync (by `updated_at`).
class NamesRepository {
  NamesRepository({
    required NamesLocalSource local,
    required NamesSeedSource seed,
    required NamesRemoteSource remote,
    required NamesSyncState syncState,
  }) : _local = local,
       _seed = seed,
       _remote = remote,
       _syncState = syncState;

  final NamesLocalSource _local;
  final NamesSeedSource _seed;
  final NamesRemoteSource _remote;
  final NamesSyncState _syncState;

  List<NameModel> _all = const [];
  Map<String, NameModel> _byId = const {};
  NameSearchIndex _index = NameSearchIndex(const []);

  Future<void>? _ready;
  Future<SyncResult>? _syncing;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Emits whenever the data set changes (e.g. after a sync).
  Stream<void> get changes => _changes.stream;

  /// Seeds (first launch) and loads the cache. Safe to call repeatedly;
  /// a failed attempt can be retried.
  Future<void> ensureReady() {
    return _ready ??= _init().catchError((Object e, StackTrace st) {
      _ready = null;
      Error.throwWithStackTrace(e, st);
    });
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// All names, most popular first.
  Future<List<NameModel>> getAll() async {
    await ensureReady();
    return _all;
  }

  Future<NameModel?> getById(String id) async {
    await ensureReady();
    return _byId[id];
  }

  /// Matches Latin spellings, Ge'ez (any vowel order / homophone letter),
  /// nicknames and meanings. Best matches first. Blank query → empty list.
  Future<List<NameModel>> search(String query, {NameFilter? filter}) async {
    await ensureReady();
    final List<NameModel> hits = _index.search(query);
    return filter == null || filter.isEmpty ? hits : filter.apply(hits);
  }

  /// Names matching [filter], most popular first.
  Future<List<NameModel>> filter(NameFilter filter) async {
    await ensureReady();
    return filter.isEmpty ? _all : filter.apply(_all);
  }

  /// Related names: curated `similar` ids first, then best-scoring matches.
  Future<List<NameModel>> similar(String id, {int limit = 10}) async {
    await ensureReady();
    final NameModel? target = _byId[id];
    if (target == null) return const [];
    return SimilarNames.find(target, _all, byId: _byId.get, limit: limit);
  }

  /// Names liked most in the last 7 days (trendScore > 0), best first.
  Future<List<NameModel>> trending({
    NameFilter filter = NameFilter.none,
    int limit = 12,
  }) async {
    final List<NameModel> list =
        [
          for (final NameModel n in await this.filter(filter))
            if (n.trendScore > 0) n,
        ]..sort((a, b) {
          final int t = b.trendScore.compareTo(a.trendScore);
          return t != 0 ? t : NameSearchIndex.compareByPopularity(a, b);
        });
    return list.take(limit).toList();
  }

  /// Looks up several ids at once, keeping their order; unknown ids skipped.
  Future<List<NameModel>> getByIds(Iterable<String> ids) async {
    await ensureReady();
    return [
      for (final String id in ids)
        if (_byId[id] case final NameModel n) n,
    ];
  }

  /// The same name for the whole (UTC) [day]. Picks from names matching
  /// [filter], falling back to all names when nothing matches.
  Future<NameModel?> nameOfTheDay(
    DateTime day, {
    NameFilter filter = NameFilter.none,
  }) async {
    final List<NameModel> matching = await this.filter(filter);
    final List<NameModel> pool = [...(matching.isEmpty ? _all : matching)]
      ..sort((a, b) => a.id.compareTo(b.id));
    if (pool.isEmpty) return null;
    final int dayNumber =
        DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    // Multiplying by a prime spreads consecutive days across the list.
    return pool[(dayNumber * 7919) % pool.length];
  }

  /// Names grouped by theme (only themes with at least [minNames] names),
  /// largest groups first. Each group is ordered by popularity.
  Future<List<ThemeGroup>> themeGroups({
    NameFilter filter = NameFilter.none,
    int minNames = 3,
  }) async {
    final Map<String, List<NameModel>> byTheme = {};
    for (final NameModel n in await this.filter(filter)) {
      for (final String t in n.themes) {
        (byTheme[t] ??= []).add(n);
      }
    }
    return [
      for (final MapEntry<String, List<NameModel>> e in byTheme.entries)
        if (e.value.length >= minNames) ThemeGroup(e.key, e.value),
    ]..sort((a, b) => b.names.length.compareTo(a.names.length));
  }

  // ---------------------------------------------------------------------------
  // Sync
  // ---------------------------------------------------------------------------

  /// Pulls names changed on the server since the last sync. Never throws:
  /// failures are reported in the result so it can run in the background.
  /// Concurrent calls share one run.
  Future<SyncResult> syncFromFirestore() {
    if (!_remote.isAvailable) {
      return Future.value(const SyncResult(SyncStatus.skipped));
    }
    return _syncing ??= _sync().whenComplete(() => _syncing = null);
  }

  Future<SyncResult> _sync() async {
    try {
      await ensureReady();
      final RemoteNameChanges changes = await _remote.fetchChangedSince(
        _syncState.lastSyncedAt,
      );
      if (changes.isEmpty) return const SyncResult(SyncStatus.success);

      final List<NameModel> newer = [
        for (final NameModel n in changes.upserts)
          if (_isNewer(n)) n,
      ];
      await _local.upsertAll(newer);
      await _local.deleteByIds(changes.deletedIds);
      if (changes.maxUpdatedAt != null) {
        await _syncState.setLastSyncedAt(changes.maxUpdatedAt!);
      }
      await _reloadCache();
      return SyncResult(
        SyncStatus.success,
        upserted: newer.length,
        deleted: changes.deletedIds.length,
      );
    } catch (error, stack) {
      CrashReporter.record(error, stack, reason: 'Names sync');
      return SyncResult(SyncStatus.failed, error: error);
    }
  }

  Future<void> dispose() => _changes.close();

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  Future<void> _init() async {
    await _mergeSeedIfNeeded();
    await _reloadCache(notify: false);
  }

  /// On first launch (empty DB) or when the app ships a newer names.json,
  /// merges the bundled names. Rows already updated by a sync are kept.
  Future<void> _mergeSeedIfNeeded() async {
    final bool isEmpty = await _local.count() == 0;
    final NamesSeed seed = await _seed.load();
    if (!isEmpty && seed.version <= _syncState.seedVersion) return;

    if (isEmpty) {
      await _local.upsertAll(seed.names);
    } else {
      final Map<String, NameModel> current = {
        for (final NameModel n in await _local.getAll()) n.id: n,
      };
      await _local.upsertAll([
        for (final NameModel n in seed.names)
          if (!current.containsKey(n.id) ||
              n.updatedAt.isAfter(current[n.id]!.updatedAt))
            n,
      ]);
    }
    await _syncState.setSeedVersion(seed.version);

    // The seed is an export of Firestore, so the next sync can start from
    // the newest seeded change instead of downloading everything again.
    final DateTime? newestSeeded = _newest(seed.names);
    final DateTime? lastSync = _syncState.lastSyncedAt;
    if (newestSeeded != null &&
        (lastSync == null || newestSeeded.isAfter(lastSync))) {
      await _syncState.setLastSyncedAt(newestSeeded);
    }
  }

  Future<void> _reloadCache({bool notify = true}) async {
    final List<NameModel> all = await _local.getAll()
      ..sort(NameSearchIndex.compareByPopularity);
    _all = List.unmodifiable(all);
    _byId = {for (final NameModel n in all) n.id: n};
    _index = NameSearchIndex(all);
    if (notify && !_changes.isClosed) _changes.add(null);
  }

  bool _isNewer(NameModel n) {
    final NameModel? existing = _byId[n.id];
    return existing == null || n.updatedAt.isAfter(existing.updatedAt);
  }

  static DateTime? _newest(List<NameModel> names) {
    DateTime? newest;
    for (final NameModel n in names) {
      if (newest == null || n.updatedAt.isAfter(newest)) newest = n.updatedAt;
    }
    return newest;
  }
}

extension on Map<String, NameModel> {
  NameModel? get(String id) => this[id];
}

class ThemeGroup {
  const ThemeGroup(this.theme, this.names);

  final String theme;
  final List<NameModel> names;
}
