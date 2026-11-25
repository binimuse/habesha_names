import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:habesha_names/app/data/providers/store_gateway.dart';
import 'package:habesha_names/app/services/ads_service.dart';
import 'package:habesha_names/app/services/purchase_service.dart';

import '../support/memory_storage.dart';

class FakeStore implements StoreGateway {
  bool available = true;
  final StreamController<List<StorePurchase>> updates =
      StreamController<List<StorePurchase>>.broadcast();
  final List<StorePurchase> completed = [];
  bool hasPastPurchase = false;
  int buys = 0;

  void emit(StorePurchaseStatus s, {bool complete = true}) => updates.add([
    StorePurchase(
      productId: PurchaseService.premiumId,
      status: s,
      needsCompletion: complete,
    ),
  ]);

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<StoreProduct?> queryProduct(String id) async =>
      StoreProduct(id: id, price: 'ETB 199.00');

  @override
  Stream<List<StorePurchase>> get purchaseUpdates => updates.stream;

  @override
  Future<void> buyNonConsumable(String productId) async => buys++;

  @override
  Future<void> restore() async {
    if (hasPastPurchase) {
      scheduleMicrotask(() => emit(StorePurchaseStatus.restored));
    }
  }

  @override
  Future<void> complete(StorePurchase purchase) async =>
      completed.add(purchase);
}

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 5));

void main() {
  group('InterstitialPolicy', () {
    final DateTime t = DateTime.utc(2026, 1, 1, 12);

    test('fires on the 25th swipe, then resets', () {
      final InterstitialPolicy p = InterstitialPolicy();
      for (int i = 0; i < 24; i++) {
        expect(p.registerSwipe(t), isFalse);
      }
      expect(p.registerSwipe(t), isTrue);
      p.markShown(t);
      expect(p.swipesSinceLast, 0);
    });

    test('max one per 3 minutes, even after 25 more swipes', () {
      final InterstitialPolicy p = InterstitialPolicy(every: 2);
      p.registerSwipe(t);
      expect(p.registerSwipe(t), isTrue);
      p.markShown(t);
      final DateTime soon = t.add(const Duration(minutes: 2));
      p.registerSwipe(soon);
      expect(p.registerSwipe(soon), isFalse); // too soon
      expect(p.registerSwipe(soon), isFalse);
      // Waits for the next swipe after the gap.
      expect(p.registerSwipe(t.add(const Duration(minutes: 3))), isTrue);
    });
  });

  test('AdInterleave puts a native ad after every 12 items', () {
    expect(AdInterleave.itemCount(5), 5);
    expect(AdInterleave.itemCount(24), 26);
    final List<String> layout = [
      for (int i = 0; i < AdInterleave.itemCount(26); i++)
        AdInterleave.isAd(i) ? 'ad' : '${AdInterleave.itemIndex(i)}',
    ];
    expect(layout[11], '11');
    expect(layout[12], 'ad');
    expect(layout[13], '12');
    expect(layout[25], 'ad');
    expect(layout.last, '25');
    expect(layout.where((x) => x != 'ad').toSet().length, 26);
  });

  group('PurchaseService', () {
    late FakeStore store;
    late MemoryStorageService storage;
    late PurchaseService s;

    setUp(() async {
      store = FakeStore();
      storage = MemoryStorageService();
      s = await PurchaseService(
        store,
        storage,
        restoreTimeout: const Duration(milliseconds: 50),
      ).init();
    });

    tearDown(() => s.onClose());

    test('loads the price', () {
      expect(s.storeAvailable.value, isTrue);
      expect(s.product.value!.price, 'ETB 199.00');
    });

    test('purchase → premium, persisted and completed', () async {
      await s.buy();
      expect(s.pending.value, isTrue);
      store.emit(StorePurchaseStatus.purchased);
      await settle();
      expect(s.isPremium.value, isTrue);
      expect(store.completed, hasLength(1));

      final PurchaseService again = await PurchaseService(
        store,
        storage,
      ).init();
      expect(again.isPremium.value, isTrue);
      again.onClose();
    });

    test('error / cancel do not grant', () async {
      await s.buy();
      store.emit(StorePurchaseStatus.error);
      await settle();
      expect(s.isPremium.value, isFalse);
      expect(s.lastFailed.value, isTrue);
      store.emit(StorePurchaseStatus.canceled, complete: false);
      await settle();
      expect(s.pending.value, isFalse);
    });

    test('restore: restored vs nothing to restore', () async {
      expect(await s.restore(), RestoreResult.nothing);
      store.hasPastPurchase = true;
      expect(await s.restore(), RestoreResult.restored);
      expect(s.isPremium.value, isTrue);
    });

    test('store unavailable', () async {
      final FakeStore off = FakeStore()..available = false;
      final PurchaseService u = await PurchaseService(off, storage).init();
      expect(await u.restore(), RestoreResult.unavailable);
      expect(await u.buy(), isFalse);
      u.onClose();
    });

    test('premium turns ads off', () async {
      final AdsService ads = AdsService(s, enabled: true);
      expect(ads.showAds, isTrue);
      store.emit(StorePurchaseStatus.purchased);
      await settle();
      expect(ads.showAds, isFalse);
      expect(AdsService(s).showAds, isFalse); // tests: unsupported platform
    });
  });
}
