import '../../services/storage_service.dart';

/// Names already swiped (liked or skipped), so the deck doesn't repeat them.
abstract interface class SeenNamesStore {
  Set<String> load();
  Future<void> save(Set<String> ids);
}

class StorageSeenNamesStore implements SeenNamesStore {
  StorageSeenNamesStore(this._storage);

  static const String _key = 'swipe.seen';

  final StorageService _storage;

  @override
  Set<String> load() => {
    for (final Object? v in _storage.read<List<dynamic>>(_key) ?? const [])
      if (v is String) v,
  };

  @override
  Future<void> save(Set<String> ids) => _storage.write(_key, ids.toList());
}
