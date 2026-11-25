import '../../services/storage_service.dart';
import 'favorites_sources.dart';

class StorageFavoritesSyncState implements FavoritesSyncState {
  StorageFavoritesSyncState(this._storage);

  final StorageService _storage;

  static String _key(String uid) => 'favorites.last_pulled_at.$uid';

  @override
  DateTime? lastPulledAt(String uid) {
    final String? raw = _storage.read<String>(_key(uid));
    return raw == null ? null : DateTime.tryParse(raw)?.toUtc();
  }

  @override
  Future<void> setLastPulledAt(String uid, DateTime value) =>
      _storage.write(_key(uid), value.toUtc().toIso8601String());
}
