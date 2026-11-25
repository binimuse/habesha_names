import 'dart:async';

import '../../services/crash_reporter.dart';
import '../models/favorite.dart';
import '../models/sync_result.dart';
import '../providers/favorites_sources.dart';

/// Local-first favorites with notes, synced to `users/{uid}/favorites`.
///
/// Every change is written locally first and flagged dirty. [sync] pulls
/// server changes since the last pull, merges them last-write-wins by
/// `updated_at`, then pushes whatever is still dirty.
class FavoritesRepository {
  FavoritesRepository({
    required FavoritesLocalSource local,
    required FavoritesRemoteSource remote,
    required FavoritesSyncState syncState,
    DateTime Function()? clock,
  }) : _local = local,
       _remote = remote,
       _syncState = syncState,
       _clock = clock ?? (() => DateTime.now().toUtc());

  final FavoritesLocalSource _local;
  final FavoritesRemoteSource _remote;
  final FavoritesSyncState _syncState;
  final DateTime Function() _clock;

  final Map<String, StoredFavorite> _items = {};
  Future<void>? _ready;
  Future<SyncResult>? _syncing;
  final StreamController<List<Favorite>> _changes =
      StreamController<List<Favorite>>.broadcast();

  /// Emits the active favorites after every change.
  Stream<List<Favorite>> get changes => _changes.stream;

  Future<void> ensureReady() => _ready ??= _load();

  /// Active (not removed) favorites, newest first.
  List<Favorite> get current {
    final List<Favorite> list = [
      for (final StoredFavorite s in _items.values)
        if (!s.favorite.deleted) s.favorite,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(list);
  }

  Future<List<Favorite>> getAll() async {
    await ensureReady();
    return current;
  }

  bool isFavorite(String nameId) => _items[nameId]?.favorite.deleted == false;

  Future<void> add(String nameId) async {
    await ensureReady();
    if (isFavorite(nameId)) return;
    final DateTime now = _clock();
    await _save(Favorite(nameId: nameId, createdAt: now, updatedAt: now));
  }

  Future<void> remove(String nameId) async {
    await ensureReady();
    final StoredFavorite? s = _items[nameId];
    if (s == null || s.favorite.deleted) return;
    await _save(s.favorite.copyWith(deleted: true, updatedAt: _clock()));
  }

  /// Returns the new state (true = now a favorite).
  Future<bool> toggle(String nameId) async {
    await ensureReady();
    if (isFavorite(nameId)) {
      await remove(nameId);
      return false;
    }
    await add(nameId);
    return true;
  }

  /// Undo for a removal: brings back the favorite with its note and date.
  Future<void> restore(Favorite favorite) async {
    await ensureReady();
    await _save(favorite.copyWith(deleted: false, updatedAt: _clock()));
  }

  Future<void> setNote(String nameId, String note) async {
    await ensureReady();
    final StoredFavorite? s = _items[nameId];
    if (s == null || s.favorite.deleted) return;
    final String trimmed = note.trim();
    if (s.favorite.note == trimmed) return;
    await _save(s.favorite.copyWith(note: trimmed, updatedAt: _clock()));
  }

  /// Never throws; concurrent calls share one run.
  Future<SyncResult> sync() {
    if (!_remote.isAvailable) {
      return Future.value(const SyncResult(SyncStatus.skipped));
    }
    return _syncing ??= _sync().whenComplete(() => _syncing = null);
  }

  Future<void> dispose() => _changes.close();

  // ---------------------------------------------------------------------------

  Future<void> _load() async {
    for (final StoredFavorite s in await _local.getAll()) {
      _items[s.favorite.nameId] = s;
    }
  }

  Future<void> _save(Favorite f) async {
    final StoredFavorite s = StoredFavorite(f, dirty: true);
    _items[f.nameId] = s;
    await _local.putAll([s]);
    _emit();
  }

  Future<SyncResult> _sync() async {
    try {
      await ensureReady();
      final String? uid = await _remote.ensureUid();
      if (uid == null) return const SyncResult(SyncStatus.skipped);

      // 1. Pull and merge (last write wins).
      final List<Favorite> remote = await _remote.pullChangedSince(
        uid,
        _syncState.lastPulledAt(uid),
      );
      final List<StoredFavorite> merged = [];
      DateTime? newestRemote;
      for (final Favorite r in remote) {
        if (newestRemote == null || r.updatedAt.isAfter(newestRemote)) {
          newestRemote = r.updatedAt;
        }
        final StoredFavorite? mine = _items[r.nameId];
        if (mine == null || r.updatedAt.isAfter(mine.favorite.updatedAt)) {
          final StoredFavorite s = StoredFavorite(r, dirty: false);
          _items[r.nameId] = s;
          merged.add(s);
        }
      }
      await _local.putAll(merged);

      // 2. Push local changes that are still newer.
      final List<Favorite> dirty = [
        for (final StoredFavorite s in _items.values)
          if (s.dirty) s.favorite,
      ];
      if (dirty.isNotEmpty) {
        await _remote.push(uid, dirty);
        final List<StoredFavorite> clean = [
          for (final Favorite f in dirty)
            if (identical(_items[f.nameId]?.favorite, f))
              _items[f.nameId] = StoredFavorite(f, dirty: false),
        ];
        await _local.putAll(clean);
      }

      if (newestRemote != null) {
        await _syncState.setLastPulledAt(uid, newestRemote);
      }
      if (merged.isNotEmpty) _emit();
      return SyncResult(
        SyncStatus.success,
        upserted: merged.length + dirty.length,
      );
    } catch (error, stack) {
      CrashReporter.record(error, stack, reason: 'Favorites sync');
      return SyncResult(SyncStatus.failed, error: error);
    }
  }

  void _emit() {
    if (!_changes.isClosed) _changes.add(current);
  }
}
