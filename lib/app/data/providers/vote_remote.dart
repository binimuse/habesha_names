import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../models/family_vote.dart';

abstract interface class VoteRemote {
  bool get isAvailable;
  Future<String?> ensureUid();

  /// Creates `votes/{autoId}` and returns the id.
  Future<String> create({
    required String ownerUid,
    required String title,
    required List<VoteOption> options,
  });

  Stream<FamilyVote?> watchVote(String id);
  Stream<List<Ballot>> watchBallots(String id);
  Stream<List<FamilyVote>> watchMine(String uid);
  Future<void> setOpen(String id, {required bool open});
}

class FirestoreVoteRemote implements VoteRemote {
  FirestoreVoteRemote(this._auth);

  final AuthService _auth;

  CollectionReference<Map<String, dynamic>> get _votes =>
      FirebaseFirestore.instance.collection('votes');

  @override
  bool get isAvailable => _auth.isAvailable;

  @override
  Future<String?> ensureUid() => _auth.ensureSignedIn();

  @override
  Future<String> create({
    required String ownerUid,
    required String title,
    required List<VoteOption> options,
  }) async {
    final DocumentReference<Map<String, dynamic>> ref = await _votes.add({
      'owner_uid': ownerUid,
      'title': title,
      'options': [for (final o in options) o.toJson()],
      'option_ids': [for (final o in options) o.nameId],
      'open': true,
      'created_at': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  static Map<String, dynamic> _withDate(Map<String, dynamic> data) => {
    ...data,
    'created_at': (data['created_at'] as Timestamp?)?.toDate(),
  };

  @override
  Stream<FamilyVote?> watchVote(String id) => _votes
      .doc(id)
      .snapshots()
      .map(
        (s) =>
            s.exists ? FamilyVote.fromJson(s.id, _withDate(s.data()!)) : null,
      );

  @override
  Stream<List<Ballot>> watchBallots(String id) => _votes
      .doc(id)
      .collection('ballots')
      .snapshots()
      .map(
        (snap) => [
          for (final QueryDocumentSnapshot<Map<String, dynamic>> d in snap.docs)
            Ballot(
              voterId: d.id,
              voterName: d.data()['voter_name'] as String? ?? '',
              choice: d.data()['choice'] as String? ?? '',
            ),
        ],
      );

  @override
  Stream<List<FamilyVote>> watchMine(String uid) => _votes
      .where('owner_uid', isEqualTo: uid)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map(
        (snap) => [
          for (final QueryDocumentSnapshot<Map<String, dynamic>> d in snap.docs)
            FamilyVote.fromJson(d.id, _withDate(d.data())),
        ],
      );

  @override
  Future<void> setOpen(String id, {required bool open}) =>
      _votes.doc(id).update({'open': open});
}
