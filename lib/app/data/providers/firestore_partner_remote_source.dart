import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../models/couple.dart';
import 'partner_remote_source.dart';

/// `couples/{code}` with `likes/{uid}_{nameId}` and `matches/{nameId}`
/// (matches are written by the `onSwipe` Cloud Function).
class FirestorePartnerRemoteSource implements PartnerRemoteSource {
  FirestorePartnerRemoteSource(this._auth, {Random? random})
    : _random = random ?? Random.secure();

  static const int _createAttempts = 8;

  final AuthService _auth;
  final Random _random;

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  DocumentReference<Map<String, dynamic>> _couple(String code) =>
      _db.collection('couples').doc(code);

  @override
  bool get isAvailable => _auth.isAvailable;

  @override
  Future<String?> ensureUid() => _auth.ensureSignedIn();

  @override
  Future<String> createCouple(String uid) async {
    for (int attempt = 0; attempt < _createAttempts; attempt++) {
      final String code = CoupleCode.generate(_random);
      final DocumentReference<Map<String, dynamic>> ref = _couple(code);
      final bool created = await _db.runTransaction((tx) async {
        if ((await tx.get(ref)).exists) return false; // code taken, retry
        tx.set(ref, {
          'code': code,
          'members': [uid],
          'created_by': uid,
          'created_at': FieldValue.serverTimestamp(),
        });
        return true;
      });
      if (created) return code;
    }
    throw const PartnerException(PartnerError.unknown);
  }

  @override
  Future<Couple> joinCouple(String code, String uid) {
    final DocumentReference<Map<String, dynamic>> ref = _couple(code);
    return _db.runTransaction((tx) async {
      final DocumentSnapshot<Map<String, dynamic>> snap = await tx.get(ref);
      if (!snap.exists) throw const PartnerException(PartnerError.notFound);
      final Couple couple = Couple.fromJson(code, snap.data()!);
      if (couple.members.contains(uid)) return couple;
      if (couple.isComplete) throw const PartnerException(PartnerError.full);
      final List<String> members = [...couple.members, uid];
      tx.update(ref, {'members': members});
      return Couple(code: code, members: members);
    });
  }

  @override
  Future<void> leaveCouple(String code, String uid) => _couple(code).update({
    'members': FieldValue.arrayRemove([uid]),
  });

  @override
  Stream<Couple?> watchCouple(String code) => _couple(code)
      .snapshots()
      // Right after a create/join transaction the first snapshot comes from
      // the local cache, which doesn't have the doc yet. Only the server may
      // say "deleted" — otherwise the app would disconnect immediately.
      .where((s) => s.exists || !s.metadata.isFromCache)
      .map((s) => s.exists ? Couple.fromJson(code, s.data()!) : null);

  @override
  Stream<List<NameMatch>> watchMatches(String code) => _couple(code)
      .collection('matches')
      .orderBy('created_at', descending: true)
      .snapshots()
      .map(
        (snap) => [
          for (final QueryDocumentSnapshot<Map<String, dynamic>> d in snap.docs)
            NameMatch(
              nameId: d.id,
              superLike: d.data()['super'] == true,
              createdAt:
                  (d.data()['created_at'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
            ),
        ],
      );

  @override
  Future<void> setLike(
    String code,
    String uid,
    String nameId, {
    required bool superLike,
  }) => _couple(code).collection('likes').doc('${uid}_$nameId').set({
    'uid': uid,
    'name_id': nameId,
    'super': superLike,
    'created_at': FieldValue.serverTimestamp(),
  });

  @override
  Future<void> deleteLike(String code, String uid, String nameId) =>
      _couple(code).collection('likes').doc('${uid}_$nameId').delete();
}
