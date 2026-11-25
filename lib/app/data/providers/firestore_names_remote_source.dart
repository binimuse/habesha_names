import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../services/firebase_service.dart';
import '../models/name_model.dart';
import 'names_remote_source.dart';

/// Reads `names/{id}` documents ordered by `updated_at`, in pages.
///
/// Documents use the same snake_case fields as `names.json`; `updated_at`
/// is a Firestore Timestamp. A doc with `deleted: true` removes the name.
class FirestoreNamesRemoteSource implements NamesRemoteSource {
  FirestoreNamesRemoteSource(this._firebase);

  static const String collection = 'names';
  static const int _pageSize = 300;

  final FirebaseService _firebase;

  @override
  bool get isAvailable => _firebase.isAvailable;

  @override
  Future<RemoteNameChanges> fetchChangedSince(DateTime? since) async {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection(collection)
        .orderBy(NameFields.updatedAt);
    if (since != null) {
      query = query.where(
        NameFields.updatedAt,
        isGreaterThan: Timestamp.fromDate(since),
      );
    }

    final List<NameModel> upserts = [];
    final List<String> deleted = [];
    DateTime? maxUpdatedAt;
    DocumentSnapshot<Map<String, dynamic>>? cursor;

    while (true) {
      Query<Map<String, dynamic>> page = query.limit(_pageSize);
      if (cursor != null) page = page.startAfterDocument(cursor);
      final QuerySnapshot<Map<String, dynamic>> snap = await page.get();

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snap.docs) {
        final Map<String, dynamic> data = _normalise(doc);
        final DateTime updatedAt = NameModel.parseDate(
          data[NameFields.updatedAt],
        );
        if (maxUpdatedAt == null || updatedAt.isAfter(maxUpdatedAt)) {
          maxUpdatedAt = updatedAt;
        }
        if (data[NameFields.deleted] == true) {
          deleted.add(data[NameFields.id] as String);
          continue;
        }
        try {
          upserts.add(NameModel.fromJson(data));
        } on FormatException catch (e) {
          // One bad document must not block the whole sync.
          debugPrint('Skipping invalid name doc ${doc.id}: $e');
        }
      }

      if (snap.docs.length < _pageSize) break;
      cursor = snap.docs.last;
    }

    return RemoteNameChanges(
      upserts: upserts,
      deletedIds: deleted,
      maxUpdatedAt: maxUpdatedAt,
    );
  }

  /// Converts Firestore types to the plain JSON shape [NameModel] expects.
  static Map<String, dynamic> _normalise(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = {...?doc.data()};
    data[NameFields.id] ??= doc.id;
    final Object? ts = data[NameFields.updatedAt];
    if (ts is Timestamp) data[NameFields.updatedAt] = ts.toDate().toUtc();
    return data;
  }
}
