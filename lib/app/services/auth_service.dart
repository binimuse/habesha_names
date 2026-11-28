import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'firebase_service.dart';

/// Firebase Auth wrapper. Starts with an anonymous account so favorites can
/// sync immediately; Google / Apple sign-in will link to it later.
class AuthService extends GetxService {
  AuthService(this._firebase);

  final FirebaseService _firebase;
  final RxnString uid = RxnString();

  /// In-flight sign-in shared by concurrent callers. Without it, services
  /// starting together each call signInAnonymously() and create separate
  /// users; earlier callers then use a uid that no longer matches the auth
  /// token and Firestore answers PERMISSION_DENIED.
  Future<String?>? _pending;

  bool get isAvailable => _firebase.isAvailable;

  /// Returns the signed-in uid, signing in anonymously if needed.
  /// Null when Firebase is unavailable or sign-in fails (e.g. offline).
  Future<String?> ensureSignedIn() {
    if (!isAvailable) return Future<String?>.value(null);
    final User? current = FirebaseAuth.instance.currentUser;
    if (current != null) {
      uid.value = current.uid;
      return Future<String?>.value(current.uid);
    }
    return _pending ??= _signIn().whenComplete(() => _pending = null);
  }

  Future<String?> _signIn() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      // Wait for the persisted session to be restored before deciding a
      // new anonymous account is needed.
      final User user =
          await auth.authStateChanges().first ??
          (await auth.signInAnonymously()).user!;
      uid.value = user.uid;
      return user.uid;
    } catch (error) {
      debugPrint('Anonymous sign-in failed: $error');
      return null;
    }
  }
}
