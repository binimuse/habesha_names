import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

enum AdminAuthState { loading, signedOut, notAdmin, admin }

/// Email + password sign-in. Only accounts with the custom claim
/// `admin: true` (set with functions/scripts/set-admin.js) get in; the same
/// claim is what firestore.rules check, so the UI gate is not the security.
class AdminAuth extends GetxService {
  final Rx<AdminAuthState> state = AdminAuthState.loading.obs;
  final RxnString email = RxnString();
  StreamSubscription<User?>? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = FirebaseAuth.instance.authStateChanges().listen(_onUser);
  }

  Future<void> _onUser(User? user) async {
    email.value = user?.email;
    if (user == null) {
      state.value = AdminAuthState.signedOut;
      return;
    }
    // Force-refresh so a freshly granted claim is seen without re-login.
    final IdTokenResult token = await user.getIdTokenResult(true);
    state.value = token.claims?['admin'] == true
        ? AdminAuthState.admin
        : AdminAuthState.notAdmin;
  }

  Future<void> signIn(String email, String password) => FirebaseAuth.instance
      .signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> signOut() => FirebaseAuth.instance.signOut();

  /// Re-checks the claim (after running set-admin.js).
  Future<void> recheck() => _onUser(FirebaseAuth.instance.currentUser);

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
