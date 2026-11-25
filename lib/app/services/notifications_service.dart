import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'firebase_service.dart';
import 'storage_service.dart';

/// Topic subscriptions + notification taps.
/// `daily_name` is sent every morning by the `nameOfTheDay` Cloud Function.
class NotificationsService extends GetxService {
  NotificationsService(this._firebase, this._storage);

  static const String dailyTopic = 'daily_name';
  static const String _kDaily = 'notifications.daily_name';

  final FirebaseService _firebase;
  final StorageService _storage;

  /// Daily name notification on/off (default on).
  final RxBool dailyEnabled = true.obs;

  /// Set when the user opens a daily-name notification; the shell opens it.
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
    } catch (error) {
      debugPrint('Notifications init failed: $error');
    }
    return this;
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

  void _onOpened(RemoteMessage m) {
    if (m.data['type'] == 'daily_name' && m.data['name_id'] is String) {
      pendingNameId.value = m.data['name_id'] as String;
    }
  }
}
