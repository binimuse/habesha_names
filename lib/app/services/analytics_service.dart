import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'firebase_service.dart';

/// Where events go (Firebase in the app, a list in tests).
abstract interface class AnalyticsSink {
  Future<void> log(String name, Map<String, Object> params);
}

class FirebaseAnalyticsSink implements AnalyticsSink {
  @override
  Future<void> log(String name, Map<String, Object> params) =>
      FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
}

/// Product analytics. Event names follow GA4 recommended events where one
/// exists (search, share, purchase), custom snake_case otherwise.
class AnalyticsService extends GetxService {
  AnalyticsService(this._sink, {required bool enabled}) : _enabled = enabled;

  factory AnalyticsService.firebase(FirebaseService firebase) =>
      AnalyticsService(FirebaseAnalyticsSink(), enabled: firebase.isAvailable);

  final AnalyticsSink _sink;
  final bool _enabled;

  /// From anywhere, without a hard dependency (no-op if not registered).
  static AnalyticsService? get maybe => Get.isRegistered<AnalyticsService>()
      ? Get.find<AnalyticsService>()
      : null;

  Future<void> search(String term, {required int results}) =>
      _log('search', {'search_term': term, 'results': results});

  Future<void> favorite(String nameId, {required bool added}) =>
      _log('favorite', {'name_id': nameId, 'action': added ? 'add' : 'remove'});

  Future<void> swipe(String nameId, {required String direction}) =>
      _log('swipe', {'name_id': nameId, 'direction': direction});

  Future<void> match(String nameId, {required bool superLike}) =>
      _log('match', {'name_id': nameId, 'super': superLike ? 1 : 0});

  Future<void> aiWaitlistJoin(String language, List<String> features) =>
      _log('ai_waitlist_join', {
        'language': language,
        'features': features.join(','),
        'feature_count': features.length,
      });

  /// [contentType]: name, share_card, reveal_video, partner_code, vote_link.
  Future<void> share(String contentType, String itemId) => _log('share', {
    'content_type': contentType,
    'item_id': itemId,
    'method': 'system_share_sheet',
  });

  Future<void> purchase({
    required String productId,
    required double value,
    required String currency,
  }) => _log('purchase', {
    'currency': currency,
    'value': value,
    'item_id': productId,
  });

  Future<void> _log(String name, Map<String, Object> params) async {
    if (!_enabled) return;
    try {
      await _sink.log(name, params);
    } catch (error) {
      debugPrint('Analytics $name failed: $error');
    }
  }
}
