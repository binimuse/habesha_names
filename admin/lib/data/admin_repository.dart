import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_name.dart';

/// A row from `suggestions/` (sent from the app's "Suggest a name" form).
class Suggestion {
  const Suggestion({
    required this.id,
    required this.nameLatin,
    required this.nameGeez,
    required this.meaning,
    required this.note,
    required this.language,
    this.createdAt,
  });

  final String id;
  final String nameLatin;
  final String nameGeez;
  final String meaning;
  final String note;
  final String language;
  final DateTime? createdAt;

  factory Suggestion.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final Map<String, dynamic> m = d.data();
    return Suggestion(
      id: d.id,
      nameLatin: (m['name_latin'] as String?) ?? '',
      nameGeez: (m['name_geez'] as String?) ?? '',
      meaning: (m['meaning'] as String?) ?? '',
      note: (m['note'] as String?) ?? '',
      language: (m['language'] as String?) ?? '',
      createdAt: (m['created_at'] as Timestamp?)?.toDate(),
    );
  }
}

/// A row from `reports/` ("Report a mistake" on the app's Name detail).
class NameReport {
  const NameReport({
    required this.id,
    required this.nameId,
    required this.nameLatin,
    required this.nameGeez,
    required this.fields,
    required this.message,
    required this.language,
    required this.status,
    this.createdAt,
    this.resolvedAt,
  });

  final String id;
  final String nameId;
  final String nameLatin;
  final String nameGeez;
  final List<String> fields;
  final String message;
  final String language;

  /// open | resolved | dismissed
  final String status;
  final DateTime? createdAt;
  final DateTime? resolvedAt;

  bool get isOpen => status == 'open';

  static const Map<String, String> fieldLabels = {
    'meaning': 'Meaning',
    'geez': 'Ge\'ez spelling',
    'spelling': 'English spelling',
    'pronunciation': 'Pronunciation',
    'gender': 'Gender',
    'origin': 'Origin / language / faith',
    'other': 'Other',
  };

  factory NameReport.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final Map<String, dynamic> m = d.data();
    return NameReport(
      id: d.id,
      nameId: (m['name_id'] as String?) ?? '',
      nameLatin: (m['name_latin'] as String?) ?? '',
      nameGeez: (m['name_geez'] as String?) ?? '',
      fields: [
        for (final Object? f in (m['fields'] as List<dynamic>? ?? const []))
          if (f is String) f,
      ],
      message: (m['message'] as String?) ?? '',
      language: (m['language'] as String?) ?? '',
      status: (m['status'] as String?) ?? 'open',
      createdAt: (m['created_at'] as Timestamp?)?.toDate(),
      resolvedAt: (m['resolved_at'] as Timestamp?)?.toDate(),
    );
  }
}

/// A row from `ai_waitlist/`.
class WaitlistEntry {
  const WaitlistEntry({
    required this.id,
    required this.text,
    required this.language,
    required this.features,
    this.createdAt,
  });

  final String id;
  final String text;
  final String language;
  final List<String> features;
  final DateTime? createdAt;

  factory WaitlistEntry.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final Map<String, dynamic> m = d.data();
    return WaitlistEntry(
      id: d.id,
      text: (m['text'] as String?) ?? '',
      language: (m['language'] as String?) ?? '',
      features: [
        for (final Object? f in (m['features'] as List<dynamic>? ?? const []))
          if (f is String) f,
      ],
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// All Firestore access for the admin app (rules require the admin claim).
class AdminRepository {
  AdminRepository([FirebaseFirestore? db])
    : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Live names — phones sync this collection.
  CollectionReference<Map<String, dynamic>> get _names =>
      _db.collection('names');

  /// Unpublished names / edits — admin-only, phones never see them.
  CollectionReference<Map<String, dynamic>> get _drafts =>
      _db.collection('name_drafts');

  Stream<List<AdminName>> watchNames() =>
      _names.snapshots().map((s) => s.docs.map(AdminName.fromDoc).toList());

  Stream<List<AdminName>> watchDrafts() =>
      _drafts.snapshots().map((s) => s.docs.map(AdminName.fromDoc).toList());

  Future<NameEntry?> getEntry(String id) async {
    final [DocumentSnapshot<Map<String, dynamic>> live, draft] =
        await Future.wait([_names.doc(id).get(), _drafts.doc(id).get()]);
    if (!live.exists && !draft.exists) return null;
    return NameEntry(
      published: live.exists ? AdminName.fromDoc(live) : null,
      draft: draft.exists ? AdminName.fromDoc(draft) : null,
    );
  }

  /// True if the id is taken by a live name or a draft.
  Future<bool> nameExists(String id) async => (await getEntry(id)) != null;

  Map<String, Object?> _liveData(AdminName n) => {
    ...n.toEditableMap(),
    'deleted': false,
    'updated_at': FieldValue.serverTimestamp(),
  };

  Map<String, Object?> _draftData(AdminName n) => {
    ...n.toEditableMap(),
    'updated_at': FieldValue.serverTimestamp(),
  };

  /// Saves without publishing; the live version (if any) is untouched.
  Future<void> saveDraft(AdminName n) => _drafts.doc(n.id).set(_draftData(n));

  /// Makes [n] live (merge keeps rarity / trend_score) and drops its draft.
  Future<void> publish(AdminName n) =>
      (_db.batch()
            ..set(_names.doc(n.id), _liveData(n), SetOptions(merge: true))
            ..delete(_drafts.doc(n.id)))
          .commit();

  Future<void> discardDraft(String id) => _drafts.doc(id).delete();

  /// Bulk write in batches of 400 (Firestore allows 500 per batch), either
  /// as drafts (default — review, then publish) or straight to live.
  Future<void> importNames(
    List<AdminName> names, {
    bool asDrafts = true,
    void Function(int done)? onProgress,
  }) async {
    const int chunk = 400;
    for (int i = 0; i < names.length; i += chunk) {
      final WriteBatch batch = _db.batch();
      final int end = (i + chunk).clamp(0, names.length);
      for (final AdminName n in names.sublist(i, end)) {
        if (asDrafts) {
          batch.set(_drafts.doc(n.id), _draftData(n));
        } else {
          batch
            ..set(_names.doc(n.id), _liveData(n), SetOptions(merge: true))
            ..delete(_drafts.doc(n.id));
        }
      }
      await batch.commit();
      onProgress?.call(end);
    }
  }

  /// Publishes many drafts at once (batches of 200 = 400 writes).
  Future<void> publishAll(
    List<AdminName> drafts, {
    void Function(int done)? onProgress,
  }) async {
    const int chunk = 200;
    for (int i = 0; i < drafts.length; i += chunk) {
      final WriteBatch batch = _db.batch();
      final int end = (i + chunk).clamp(0, drafts.length);
      for (final AdminName n in drafts.sublist(i, end)) {
        batch
          ..set(_names.doc(n.id), _liveData(n), SetOptions(merge: true))
          ..delete(_drafts.doc(n.id));
      }
      await batch.commit();
      onProgress?.call(end);
    }
  }

  /// Soft delete: phones remove the name on their next sync.
  Future<void> setDeleted(String id, {required bool deleted}) => _names
      .doc(id)
      .update({'deleted': deleted, 'updated_at': FieldValue.serverTimestamp()});

  Stream<List<Suggestion>> watchSuggestions() => _db
      .collection('suggestions')
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Suggestion.fromDoc).toList());

  Future<void> deleteSuggestion(String id) =>
      _db.collection('suggestions').doc(id).delete();

  /// All reports, newest first (status is filtered in the UI).
  Stream<List<NameReport>> watchReports() => _db
      .collection('reports')
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((s) => s.docs.map(NameReport.fromDoc).toList());

  /// open → resolved / dismissed, or back to open.
  Future<void> setReportStatus(String id, String status) =>
      _db.collection('reports').doc(id).update({
        'status': status,
        'resolved_at': status == 'open' ? null : FieldValue.serverTimestamp(),
      });

  Stream<List<WaitlistEntry>> watchWaitlist() => _db
      .collection('ai_waitlist')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(WaitlistEntry.fromDoc).toList());
}
