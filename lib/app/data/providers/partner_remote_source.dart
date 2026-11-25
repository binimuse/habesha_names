import '../models/couple.dart';

/// Server side of the partner link. Methods throw [PartnerException].
abstract interface class PartnerRemoteSource {
  bool get isAvailable;

  /// Signs in (anonymously if needed). Null when not possible.
  Future<String?> ensureUid();

  /// Creates a couple with [uid] as the only member; returns its code.
  Future<String> createCouple(String uid);

  /// Adds [uid] to the couple. Joining your own couple again is a no-op.
  Future<Couple> joinCouple(String code, String uid);

  Future<void> leaveCouple(String code, String uid);

  /// Emits null if the couple no longer exists.
  Stream<Couple?> watchCouple(String code);

  /// Newest first.
  Stream<List<NameMatch>> watchMatches(String code);

  Future<void> setLike(
    String code,
    String uid,
    String nameId, {
    required bool superLike,
  });

  Future<void> deleteLike(String code, String uid, String nameId);
}
