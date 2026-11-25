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

  bool get isAvailable => _firebase.isAvailable;

  /// Returns the signed-in uid, signing in anonymously if needed.
  /// Null when Firebase is unavailable or sign-in fails (e.g. offline).
  Future<String?> ensureSignedIn() async {
    if (!isAvailable) return null;
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User user =
          auth.currentUser ?? (await auth.signInAnonymously()).user!;
      uid.value = user.uid;
      return user.uid;
    } catch (error) {
      debugPrint('Anonymous sign-in failed: $error');
      return null;
    }
  }
}
