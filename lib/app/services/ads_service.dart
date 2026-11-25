import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../routes/app_pages.dart';
import 'purchase_service.dart';

/// Google's official TEST ad unit ids. Replace before release.
abstract final class AdUnits {
  static bool get _ios => !kIsWeb && Platform.isIOS;

  static String get banner => _ios
      ? 'ca-app-pub-3940256099942544/2934735716'
      : 'ca-app-pub-3940256099942544/6300978111';

  static String get interstitial => _ios
      ? 'ca-app-pub-3940256099942544/4411468910'
      : 'ca-app-pub-3940256099942544/1033173712';

  static String get native => _ios
      ? 'ca-app-pub-3940256099942544/3986624511'
      : 'ca-app-pub-3940256099942544/2247696110';
}

/// Interstitial frequency: after every [every] swipes, at most once per
/// [minGap]. If the gap hasn't passed yet, it waits for a later swipe.
class InterstitialPolicy {
  InterstitialPolicy({
    this.every = 25,
    this.minGap = const Duration(minutes: 3),
  });

  final int every;
  final Duration minGap;

  int _swipes = 0;
  DateTime? _lastShown;

  int get swipesSinceLast => _swipes;

  /// Counts a swipe; true when an interstitial should be shown now.
  bool registerSwipe(DateTime now) {
    _swipes++;
    if (_swipes < every) return false;
    final DateTime? last = _lastShown;
    return last == null || now.difference(last) >= minGap;
  }

  void markShown(DateTime now) {
    _swipes = 0;
    _lastShown = now;
  }
}

/// Native ad slots in long lists: one after every [every] items.
abstract final class AdInterleave {
  static int itemCount(int items, {int every = 12}) =>
      items + (every <= 0 ? 0 : items ~/ every);

  /// True if list position [i] is an ad.
  static bool isAd(int i, {int every = 12}) =>
      every > 0 && (i + 1) % (every + 1) == 0;

  /// Item index for a non-ad position.
  static int itemIndex(int i, {int every = 12}) =>
      every <= 0 ? i : i - (i + 1) ~/ (every + 1);
}

/// Banner (Name detail), native (lists) and interstitial (Swipe).
/// Disabled for Premium users and on unsupported platforms / tests.
class AdsService extends GetxService {
  AdsService(this._purchases, {bool? enabled, InterstitialPolicy? policy})
    : _enabled = enabled ?? (!kIsWeb && (Platform.isAndroid || Platform.isIOS)),
      policy = policy ?? InterstitialPolicy();

  /// Routes where an interstitial must never appear.
  static const Set<String> _quietRoutes = {Routes.match, Routes.matches};

  final PurchaseService _purchases;
  final bool _enabled;
  final InterstitialPolicy policy;
  InterstitialAd? _interstitial;

  bool get showAds => _enabled && !_purchases.isPremium.value;

  Future<AdsService> init() async {
    if (!_enabled) return this;
    try {
      await MobileAds.instance.initialize();
      _loadInterstitial();
    } catch (error) {
      debugPrint('Ads init failed: $error');
    }
    return this;
  }

  /// Call on every Swipe card swiped.
  void onSwipe() {
    if (!showAds) return;
    final DateTime now = DateTime.now();
    if (!policy.registerSwipe(now)) return;
    if (_quietRoutes.contains(Get.currentRoute)) return;
    final InterstitialAd? ad = _interstitial;
    if (ad == null) return;
    _interstitial = null;
    policy.markShown(now);
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        _loadInterstitial();
      },
    );
    ad.show();
  }

  void _loadInterstitial() {
    if (!showAds) return;
    InterstitialAd.load(
      adUnitId: AdUnits.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (error) => debugPrint('Interstitial: $error'),
      ),
    );
  }

  @override
  void onClose() {
    _interstitial?.dispose();
    super.onClose();
  }
}
