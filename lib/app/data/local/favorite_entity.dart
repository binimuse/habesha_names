import 'package:isar_community/isar.dart';

import '../models/favorite.dart';
import 'name_entity.dart' show fastHash;

part 'favorite_entity.g.dart';

@collection
class FavoriteEntity {
  Id get isarId => fastHash(nameId);

  @Index(unique: true, replace: true)
  late String nameId;

  late String note;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool deleted;
  late bool dirty;

  static FavoriteEntity fromStored(StoredFavorite s) => FavoriteEntity()
    ..nameId = s.favorite.nameId
    ..note = s.favorite.note
    ..createdAt = s.favorite.createdAt
    ..updatedAt = s.favorite.updatedAt
    ..deleted = s.favorite.deleted
    ..dirty = s.dirty;

  StoredFavorite toStored() => StoredFavorite(
    Favorite(
      nameId: nameId,
      note: note,
      createdAt: createdAt.toUtc(),
      updatedAt: updatedAt.toUtc(),
      deleted: deleted,
    ),
    dirty: dirty,
  );
}
