import '../models/name_model.dart';

/// Changes on the server since the last sync.
class RemoteNameChanges {
  const RemoteNameChanges({
    this.upserts = const [],
    this.deletedIds = const [],
    this.maxUpdatedAt,
  });

  static const RemoteNameChanges empty = RemoteNameChanges();

  final List<NameModel> upserts;
  final List<String> deletedIds;

  /// Newest server `updated_at` seen — the next sync's starting point.
  final DateTime? maxUpdatedAt;

  bool get isEmpty => upserts.isEmpty && deletedIds.isEmpty;
}

abstract interface class NamesRemoteSource {
  /// False when Firebase isn't configured / initialised on this build.
  bool get isAvailable;

  /// All names with `updated_at` strictly after [since] (all if null).
  Future<RemoteNameChanges> fetchChangedSince(DateTime? since);
}
