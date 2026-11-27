import 'dart:async';

import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/providers/device_token_remote.dart';
import 'auth_service.dart';
import 'firebase_service.dart';
import 'storage_service.dart';

/// Topic subscriptions, this install's push target (FID), and notification taps.
///
/// - `daily_name` topic: sent every morning by the `nameOfTheDay` function.
/// - Device FID at `users/{uid}/devices/{fid}` (with the UI language):
///   lets the `onSwipe` function push "It's a match!" to the partner.
class NotificationsService extends GetxService {
  NotificationsService(
    this._firebase,
    this._storage, {
    AuthService? auth,
    DeviceTokenRemote? devices,
    Rx<Locale>? locale,
  }) : _auth = auth,
       _devices = devices,
       _locale = locale;

  static const String dailyTopic = 'daily_name';
  static const String _kDaily = 'notifications.daily_name';

  final FirebaseService _firebase;
  final StorageService _storage;
  final AuthService? _auth;
  final DeviceTokenRemote? _devices;
  final Rx<Locale>? _locale;
  StreamSubscription<String>? _fidSub;
  String? _fid;
  Worker? _localeWorker;

  /// Daily name notification on/off (default on).
  final RxBool dailyEnabled = true.obs;

  /// Set when the user opens a name notification; the shell opens it.
  final RxnString pendingNameId = RxnString();

  bool get isAvailable => _firebase.isAvailable;

  Future<NotificationsService> init() async {
    dailyEnabled.value = _storage.read<bool>(_kDaily) ?? true;
    if (!isAvailable) return this;
    try {
      final RemoteMessage? initial = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initial != null) _onOpened(initial);
      FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);
      if (dailyEnabled.value) {
        unawaited(FirebaseMessaging.instance.subscribeToTopic(dailyTopic));
      }
      if (_auth != null && _devices != null) {
        // The FID (Firebase Installation ID) is the direct-send target.
        // Messaging's onRegistered only fires on first registration, so
        // read the FID directly on every launch and follow its changes.
        _fidSub = FirebaseInstallations.instance.onIdChange.listen(_setFid);
        unawaited(FirebaseMessaging.instance.register());
        unawaited(FirebaseInstallations.instance.getId().then(_setFid));
        final Rx<Locale>? locale = _locale;
        if (locale != null) {
          _localeWorker = ever(locale, (_) => _saveDevice());
        }
      }
    } catch (error) {
      debugPrint('Notifications init failed: $error');
    }
    return this;
  }

  /// Language the server should use for pushes to this device.
  static String pushLanguage(Locale? locale) =>
      locale?.languageCode == 'am' ? 'am' : 'en';

  void _setFid(String fid) {
    if (fid.isEmpty || fid == _fid) return;
    _fid = fid;
    unawaited(_saveDevice());
  }

  /// Saves this install's FID (and UI language) for targeted pushes.
  Future<void> _saveDevice() async {
    final String? fid = _fid;
    if (fid == null) return;
    try {
      final String? uid = await _auth!.ensureSignedIn();
      if (uid == null) return;
      await _devices!.save(
        uid: uid,
        fid: fid,
        language: pushLanguage(_locale?.value),
      );
    } catch (error) {
      debugPrint('Push registration failed: $error');
    }
  }

  /// Called once after onboarding: ask permission, then subscribe.
  Future<void> requestAndSubscribe() async {
    if (!isAvailable || !dailyEnabled.value) return;
    try {
      await FirebaseMessaging.instance.requestPermission();
      await FirebaseMessaging.instance.subscribeToTopic(dailyTopic);
    } catch (error) {
      debugPrint('Daily name subscribe failed: $error');
    }
  }

  Future<void> setDaily(bool on) async {
    dailyEnabled.value = on;
    await _storage.write(_kDaily, on);
    if (!isAvailable) return;
    try {
      if (on) {
        await FirebaseMessaging.instance.requestPermission();
        await FirebaseMessaging.instance.subscribeToTopic(dailyTopic);
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic(dailyTopic);
      }
    } catch (error) {
      debugPrint('Daily name toggle failed: $error');
    }
  }

  /// Daily-name and partner-match pushes both open that name.
  void _onOpened(RemoteMessage m) {
    const Set<String> opensName = {'daily_name', 'match'};
    if (opensName.contains(m.data['type']) && m.data['name_id'] is String) {
      pendingNameId.value = m.data['name_id'] as String;
    }
  }

  @override
  void onClose() {
    _fidSub?.cancel();
    _localeWorker?.dispose();
    super.onClose();
  }
}
