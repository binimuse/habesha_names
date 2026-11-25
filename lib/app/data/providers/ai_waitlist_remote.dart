import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../services/analytics_service.dart';
import '../../services/auth_service.dart';
import '../models/ai_feature.dart';

/// Server side of the AI waitlist.
abstract interface class AiWaitlistRemote {
  bool get isAvailable;

  Future<String?> ensureUid();

  /// Writes `ai_waitlist/{autoId}`.
  Future<void> addEntry({
    required String uid,
    required String text,
    required String language,
    required List<AiFeature> features,
  });

  Future<void> logJoin({
    required String language,
    required List<AiFeature> features,
  });

  /// Asks for notification permission and subscribes to the launch topic.
  Future<void> subscribeToLaunch();
}

class FirebaseAiWaitlistRemote implements AiWaitlistRemote {
  FirebaseAiWaitlistRemote(this._auth);

  static const String collection = 'ai_waitlist';
  static const String launchTopic = 'ai_launch';
  static const String joinEvent = 'ai_waitlist_join';

  final AuthService _auth;

  @override
  bool get isAvailable => _auth.isAvailable;

  @override
  Future<String?> ensureUid() => _auth.ensureSignedIn();

  @override
  Future<void> addEntry({
    required String uid,
    required String text,
    required String language,
    required List<AiFeature> features,
  }) => FirebaseFirestore.instance.collection(collection).add({
    'uid': uid,
    'text': text,
    'language': language,
    'features': [for (final AiFeature f in features) f.code],
    'createdAt': FieldValue.serverTimestamp(),
  });

  @override
  Future<void> logJoin({
    required String language,
    required List<AiFeature> features,
  }) async => AnalyticsService.maybe?.aiWaitlistJoin(language, [
    for (final AiFeature f in features) f.code,
  ]);

  @override
  Future<void> subscribeToLaunch() async {
    final FirebaseMessaging fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    await fcm.subscribeToTopic(launchTopic);
  }
}
