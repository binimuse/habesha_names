import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/admin_auth.dart';
import 'admin_shell.dart';
import 'login_page.dart';

/// Login → "not an admin" → the admin shell.
class AuthGate extends GetView<AdminAuth> {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => switch (controller.state.value) {
        AdminAuthState.loading => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        AdminAuthState.signedOut => const LoginPage(),
        AdminAuthState.notAdmin => const _NotAdmin(),
        AdminAuthState.admin => const AdminShell(),
      },
    );
  }
}

class _NotAdmin extends GetView<AdminAuth> {
  const _NotAdmin();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 48),
                const SizedBox(height: 16),
                Text(
                  'No admin access',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Text(
                    '${controller.email.value ?? 'This account'} is signed in '
                    'but is not an admin. Run '
                    '"node scripts/set-admin.js <email>" in functions/, '
                    'then check again.',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  children: [
                    FilledButton(
                      onPressed: controller.recheck,
                      child: const Text('Check again'),
                    ),
                    OutlinedButton(
                      onPressed: controller.signOut,
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
