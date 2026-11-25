import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../models/favorite.dart';
import 'favorites_sources.dart';

class FirestoreFavoritesRemoteSource implements FavoritesRemoteSource {
  FirestoreFavoritesRemoteSource(this._auth);

  static const int _batchLimit = 450; // Firestore max is 500 writes / batch

  final AuthService _auth;

  @override
  bool get isAvailable => _auth.isAvailable;

  @override
  Future<String?> ensureUid() => _auth.ensureSignedIn();

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      FirebaseFirestore.instance.collection('users/$uid/favorites');

  @override
  Future<List<Favorite>> pullChangedSince(String uid, DateTime? since) async {
    Query<Map<String, dynamic>> q = _col(uid).orderBy('updated_at');
    if (since != null) {
      q = q.where('updated_at', isGreaterThan: Timestamp.fromDate(since));
    }
    final QuerySnapshot<Map<String, dynamic>> snap = await q.get();
    return [
      for (final QueryDocumentSnapshot<Map<String, dynamic>> d in snap.docs)
        Favorite.fromJson({
          ...d.data(),
          'name_id': d.data()['name_id'] ?? d.id,
          'created_at': _toDate(d.data()['created_at']),
          'updated_at': _toDate(d.data()['updated_at']),
        }),
    ];
  }

  @override
  Future<void> push(String uid, List<Favorite> items) async {
    for (int i = 0; i < items.length; i += _batchLimit) {
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      for (final Favorite f in items.skip(i).take(_batchLimit)) {
        batch.set(_col(uid).doc(f.nameId), {
          'name_id': f.nameId,
          'note': f.note,
          'created_at': Timestamp.fromDate(f.createdAt),
          'updated_at': Timestamp.fromDate(f.updatedAt),
          'deleted': f.deleted,
        });
      }
      await batch.commit();
    }
  }

  static DateTime _toDate(Object? v) => switch (v) {
    final Timestamp t => t.toDate().toUtc(),
    final DateTime d => d.toUtc(),
    final String s => DateTime.parse(s).toUtc(),
    _ => DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  };
}
