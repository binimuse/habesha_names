/// A saved name with the parent's note. Removals are kept as tombstones
/// ([deleted] = true) so they sync to other devices.
class Favorite {
  const Favorite({
    required this.nameId,
    required this.createdAt,
    required this.updatedAt,
    this.note = '',
    this.deleted = false,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
    nameId: json['name_id'] as String,
    note: json['note'] as String? ?? '',
    createdAt: _date(json['created_at']),
    updatedAt: _date(json['updated_at']),
    deleted: json['deleted'] as bool? ?? false,
  );

  final String nameId;
  final String note;
  final DateTime createdAt;

  /// Last change, used for last-write-wins merging across devices.
  final DateTime updatedAt;
  final bool deleted;

  Favorite copyWith({String? note, DateTime? updatedAt, bool? deleted}) =>
      Favorite(
        nameId: nameId,
        createdAt: createdAt,
        note: note ?? this.note,
        updatedAt: updatedAt ?? this.updatedAt,
        deleted: deleted ?? this.deleted,
      );

  Map<String, dynamic> toJson() => {
    'name_id': nameId,
    'note': note,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted': deleted,
  };

  static DateTime _date(Object? v) =>
      v is DateTime ? v.toUtc() : DateTime.parse(v! as String).toUtc();
}

/// A [Favorite] as stored on the device, with its sync flag.
class StoredFavorite {
  const StoredFavorite(this.favorite, {required this.dirty});

  final Favorite favorite;

  /// Changed locally and not yet pushed to the server.
  final bool dirty;
}
