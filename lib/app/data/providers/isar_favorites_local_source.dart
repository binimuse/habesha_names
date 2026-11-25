import 'package:isar_community/isar.dart';

import '../local/favorite_entity.dart';
import '../models/favorite.dart';
import 'favorites_sources.dart';

class IsarFavoritesLocalSource implements FavoritesLocalSource {
  IsarFavoritesLocalSource(this._isar);

  final Isar _isar;

  @override
  Future<List<StoredFavorite>> getAll() async => [
    for (final FavoriteEntity e
        in await _isar.favoriteEntitys.where().findAll())
      e.toStored(),
  ];

  @override
  Future<void> putAll(List<StoredFavorite> items) async {
    if (items.isEmpty) return;
    await _isar.writeTxn(
      () => _isar.favoriteEntitys.putAll([
        for (final StoredFavorite s in items) FavoriteEntity.fromStored(s),
      ]),
    );
  }
}
