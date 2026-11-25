import '../models/favorite.dart';

abstract interface class FavoritesLocalSource {
  Future<List<StoredFavorite>> getAll();
  Future<void> putAll(List<StoredFavorite> items);
}

/// Server copy at `users/{uid}/favorites/{nameId}`.
abstract interface class FavoritesRemoteSource {
  bool get isAvailable;

  /// Signs in (anonymously if needed). Null when sign-in isn't possible.
  Future<String?> ensureUid();

  Future<List<Favorite>> pullChangedSince(String uid, DateTime? since);
  Future<void> push(String uid, List<Favorite> items);
}

abstract interface class FavoritesSyncState {
  DateTime? lastPulledAt(String uid);
  Future<void> setLastPulledAt(String uid, DateTime value);
}
