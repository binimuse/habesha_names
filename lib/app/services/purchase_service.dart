import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../data/providers/store_gateway.dart';
import 'analytics_service.dart';
import 'storage_service.dart';

enum RestoreResult { restored, nothing, unavailable }

/// "Habesha Names Premium": one-time, non-consumable. Removes ads, unlocks
/// every share-card template and caches pronunciation audio for offline use.
///
/// Entitlement is cached on the device and refreshed from the store's
/// purchase / restore events. For stronger protection, verify receipts on a
/// server (Cloud Function) before granting — see TODO below.
class PurchaseService extends GetxService {
  PurchaseService(this._store, this._storage, {Duration? restoreTimeout})
    : _restoreTimeout = restoreTimeout ?? const Duration(seconds: 6);

  static const String premiumId = 'habesha_names_premium';
  static const String _kPremium = 'premium.active';

  final StoreGateway _store;
  final StorageService _storage;
  final Duration _restoreTimeout;

  final RxBool isPremium = false.obs;
  final RxBool storeAvailable = false.obs;
  final Rxn<StoreProduct> product = Rxn<StoreProduct>();
  final RxBool pending = false.obs;

  /// Set when the last purchase attempt failed.
  final RxBool lastFailed = false.obs;

  StreamSubscription<List<StorePurchase>>? _sub;
  Completer<bool>? _restoring;

  Future<PurchaseService> init() async {
    isPremium.value = _storage.read<bool>(_kPremium) ?? false;
    try {
      _sub = _store.purchaseUpdates.listen(_onUpdates);
      storeAvailable.value = await _store.isAvailable();
      if (storeAvailable.value) {
        product.value = await _store.queryProduct(premiumId);
      }
    } catch (error) {
      debugPrint('Store unavailable: $error');
      storeAvailable.value = false;
    }
    return this;
  }

  Future<bool> buy() async {
    if (!storeAvailable.value || isPremium.value) return false;
    lastFailed.value = false;
    try {
      pending.value = true;
      await _store.buyNonConsumable(premiumId);
      return true;
    } catch (error) {
      debugPrint('Purchase failed to start: $error');
      pending.value = false;
      lastFailed.value = true;
      return false;
    }
  }

  /// Asks the store to replay past purchases; waits briefly for a result.
  Future<RestoreResult> restore() async {
    if (!storeAvailable.value) return RestoreResult.unavailable;
    final Completer<bool> done = _restoring = Completer<bool>();
    try {
      await _store.restore();
    } catch (error) {
      debugPrint('Restore failed: $error');
      _restoring = null;
      return RestoreResult.unavailable;
    }
    final bool restored = await done.future.timeout(
      _restoreTimeout,
      onTimeout: () => false,
    );
    _restoring = null;
    return restored || isPremium.value
        ? RestoreResult.restored
        : RestoreResult.nothing;
  }

  Future<void> _onUpdates(List<StorePurchase> purchases) async {
    for (final StorePurchase p in purchases) {
      if (p.productId != premiumId) continue;
      switch (p.status) {
        case StorePurchaseStatus.pending:
          pending.value = true;
        case StorePurchaseStatus.purchased || StorePurchaseStatus.restored:
          // TODO(iap): verify the receipt server-side before granting.
          final bool isNew =
              p.status == StorePurchaseStatus.purchased && !isPremium.value;
          await _grant();
          if (isNew) {
            unawaited(
              AnalyticsService.maybe?.purchase(
                productId: premiumId,
                value: product.value?.rawPrice ?? 0,
                currency: product.value?.currency ?? '',
              ),
            );
          }
          if (!(_restoring?.isCompleted ?? true)) _restoring!.complete(true);
        case StorePurchaseStatus.error:
          pending.value = false;
          lastFailed.value = true;
        case StorePurchaseStatus.canceled:
          pending.value = false;
      }
      if (p.needsCompletion) {
        try {
          await _store.complete(p);
        } catch (error) {
          debugPrint('completePurchase failed: $error');
        }
      }
    }
  }

  Future<void> _grant() async {
    pending.value = false;
    lastFailed.value = false;
    isPremium.value = true;
    await _storage.write(_kPremium, true);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
