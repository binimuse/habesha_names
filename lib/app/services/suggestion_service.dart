import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'auth_service.dart';

/// A name a user thinks is missing from the catalogue.
class NameSuggestion {
  const NameSuggestion({
    required this.nameLatin,
    this.nameGeez = '',
    this.meaning = '',
    this.note = '',
  });

  final String nameLatin;
  final String nameGeez;
  final String meaning;
  final String note;

  static const int maxShort = 60;
  static const int maxLong = 500;
}

abstract interface class SuggestionRemote {
  bool get isAvailable;
  Future<String?> ensureUid();
  Future<void> add(Map<String, Object> data);
}

class FirestoreSuggestionRemote implements SuggestionRemote {
  FirestoreSuggestionRemote(this._auth);

  final AuthService _auth;

  @override
  bool get isAvailable => _auth.isAvailable;

  @override
  Future<String?> ensureUid() => _auth.ensureSignedIn();

  @override
  Future<void> add(Map<String, Object> data) => FirebaseFirestore.instance
      .collection('suggestions')
      .add({...data, 'created_at': FieldValue.serverTimestamp()});
}

class SuggestionException implements Exception {
  const SuggestionException(this.reason);

  final String reason;
}

/// Writes `suggestions/{autoId}` (create-only, see firestore.rules).
class SuggestionService extends GetxService {
  SuggestionService(this._remote);

  final SuggestionRemote _remote;

  Future<void> submit(NameSuggestion s, {required String language}) async {
    String clip(String v, int max) {
      final String t = v.trim();
      return t.length > max ? t.substring(0, max) : t;
    }

    final String latin = clip(s.nameLatin, NameSuggestion.maxShort);
    if (latin.isEmpty) throw const SuggestionException('name');
    if (!_remote.isAvailable) throw const SuggestionException('unavailable');
    final String? uid = await _remote.ensureUid();
    if (uid == null) throw const SuggestionException('unavailable');
    try {
      await _remote.add({
        'uid': uid,
        'name_latin': latin,
        'name_geez': clip(s.nameGeez, NameSuggestion.maxShort),
        'meaning': clip(s.meaning, NameSuggestion.maxLong),
        'note': clip(s.note, NameSuggestion.maxLong),
        'language': language,
      });
    } catch (_) {
      throw const SuggestionException('failed');
    }
  }
}
