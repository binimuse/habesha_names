import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Crashlytics wiring. Before Firebase is configured (or in debug builds)
/// errors are only printed.
abstract final class CrashReporter {
  static bool _enabled = false;

  /// Call once Firebase is initialised.
  static Future<void> init({required bool firebaseAvailable}) async {
    _enabled = firebaseAvailable && !kDebugMode;
    if (!firebaseAvailable) return;
    final FirebaseCrashlytics c = FirebaseCrashlytics.instance;
    await c.setCrashlyticsCollectionEnabled(_enabled);
    if (!_enabled) return;
    FlutterError.onError = c.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      c.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Non-fatal error (sync failures, export failures…).
  static void record(Object error, StackTrace? stack, {String? reason}) {
    debugPrint('${reason ?? 'Error'}: $error');
    if (!_enabled) return;
    FirebaseCrashlytics.instance.recordError(error, stack, reason: reason);
  }
}
