import '../../core/constants/app_constants.dart';
import '../../services/storage_service.dart';

/// Remembers how far the local names DB is in sync.
abstract interface class NamesSyncState {
  DateTime? get lastSyncedAt;
  Future<void> setLastSyncedAt(DateTime value);

  /// Version of the bundled names.json last merged into the DB (0 = never).
  int get seedVersion;
  Future<void> setSeedVersion(int value);
}

class StorageNamesSyncState implements NamesSyncState {
  StorageNamesSyncState(this._storage);

  final StorageService _storage;

  @override
  DateTime? get lastSyncedAt {
    final String? raw = _storage.read<String>(StorageKeys.namesLastSyncedAt);
    return raw == null ? null : DateTime.tryParse(raw)?.toUtc();
  }

  @override
  Future<void> setLastSyncedAt(DateTime value) => _storage.write(
    StorageKeys.namesLastSyncedAt,
    value.toUtc().toIso8601String(),
  );

  @override
  int get seedVersion => _storage.read<int>(StorageKeys.namesSeedVersion) ?? 0;

  @override
  Future<void> setSeedVersion(int value) =>
      _storage.write(StorageKeys.namesSeedVersion, value);
}
