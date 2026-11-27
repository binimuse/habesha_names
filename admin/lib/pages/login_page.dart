import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/admin_auth.dart';

class LoginController extends GetxController {
  LoginController(this._auth);

  final AdminAuth _auth;
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final RxBool busy = false.obs;
  final RxnString error = RxnString();

  Future<void> submit() async {
    if (busy.value) return;
    busy.value = true;
    error.value = null;
    try {
      await _auth.signIn(email.text, password.text);
    } on FirebaseAuthException catch (e) {
      error.value = switch (e.code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' => 'Wrong email or password.',
        'invalid-email' => 'That email address is not valid.',
        'too-many-requests' => 'Too many attempts. Try again later.',
        'operation-not-allowed' =>
          'Email/Password sign-in is not enabled in Firebase Authentication.',
        _ => 'Sign-in failed (${e.code}).',
      };
    } finally {
      busy.value = false;
    }
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController c = Get.put(LoginController(Get.find()));
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: AutofillGroup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Habesha Names Admin',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: c.email,
                      autofillHints: const [AutofillHints.email],
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: c.password,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration: const InputDecoration(labelText: 'Password'),
                      onSubmitted: (_) => c.submit(),
                    ),
                    Obx(
                      () => c.error.value == null
                          ? const SizedBox(height: 20)
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                c.error.value!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                    ),
                    Obx(
                      () => FilledButton(
                        onPressed: c.busy.value ? null : c.submit,
                        child: c.busy.value
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Sign in'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
