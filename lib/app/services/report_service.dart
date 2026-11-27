import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../data/models/name_model.dart';
import 'auth_service.dart';

/// Which part of a name the user thinks is wrong.
enum ReportField {
  meaning('meaning'),
  geez('geez'),
  spelling('spelling'),
  pronunciation('pronunciation'),
  gender('gender'),
  origin('origin'),
  other('other');

  const ReportField(this.code);

  /// Stored in Firestore (`fields` list); must match firestore.rules.
  final String code;
}

abstract interface class ReportRemote {
  bool get isAvailable;
  Future<String?> ensureUid();
  Future<void> add(Map<String, Object> data);
}

class FirestoreReportRemote implements ReportRemote {
  FirestoreReportRemote(this._auth);

  final AuthService _auth;

  @override
  bool get isAvailable => _auth.isAvailable;

  @override
  Future<String?> ensureUid() => _auth.ensureSignedIn();

  @override
  Future<void> add(Map<String, Object> data) => FirebaseFirestore.instance
      .collection('reports')
      .add({...data, 'created_at': FieldValue.serverTimestamp()});
}

class ReportException implements Exception {
  const ReportException(this.reason);

  /// `input` (nothing picked / note too short), `unavailable`, `failed`.
  final String reason;
}

/// "Report a mistake" on Name detail → `reports/{autoId}` (create-only for
/// users; the admin app reviews them and fixes the name).
class ReportService extends GetxService {
  ReportService(this._remote);

  static const int minMessage = 3;
  static const int maxMessage = 500;

  final ReportRemote _remote;

  bool get isAvailable => _remote.isAvailable;

  Future<void> submit(
    NameModel name, {
    required Set<ReportField> fields,
    required String message,
    required String language,
  }) async {
    final String text = message.trim();
    if (fields.isEmpty || text.length < minMessage) {
      throw const ReportException('input');
    }
    if (!_remote.isAvailable) throw const ReportException('unavailable');
    final String? uid = await _remote.ensureUid();
    if (uid == null) throw const ReportException('unavailable');
    try {
      await _remote.add({
        'uid': uid,
        'name_id': name.id,
        // Snapshot so the admin sees what the user saw.
        'name_latin': name.nameLatin,
        'name_geez': name.nameGeez,
        'fields': [
          for (final ReportField f in ReportField.values)
            if (fields.contains(f)) f.code,
        ],
        'message': text.length > maxMessage
            ? text.substring(0, maxMessage)
            : text,
        'language': language == 'am' ? 'am' : 'en',
        'status': 'open',
      });
    } catch (_) {
      throw const ReportException('failed');
    }
  }
}
