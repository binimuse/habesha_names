import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

enum StorePurchaseStatus { pending, purchased, restored, error, canceled }

class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.price,
    this.rawPrice = 0,
    this.currency = '',
  });

  final String id;

  /// Localised price string from the store, e.g. "ETB 199.00".
  final String price;

  /// Numeric price and ISO currency (for the purchase analytics event).
  final double rawPrice;
  final String currency;
}

class StorePurchase {
  const StorePurchase({
    required this.productId,
    required this.status,
    this.needsCompletion = false,
    this.raw,
  });

  final String productId;
  final StorePurchaseStatus status;
  final bool needsCompletion;

  /// Underlying plugin object (needed to complete the purchase).
  final Object? raw;
}

/// Thin seam over the store so purchase logic is testable.
abstract interface class StoreGateway {
  Future<bool> isAvailable();
  Future<StoreProduct?> queryProduct(String id);
  Stream<List<StorePurchase>> get purchaseUpdates;
  Future<void> buyNonConsumable(String productId);
  Future<void> restore();
  Future<void> complete(StorePurchase purchase);
}

class InAppPurchaseGateway implements StoreGateway {
  InAppPurchase get _iap => InAppPurchase.instance;
  final Map<String, ProductDetails> _products = {};

  @override
  Future<bool> isAvailable() => _iap.isAvailable();

  @override
  Future<StoreProduct?> queryProduct(String id) async {
    final ProductDetailsResponse r = await _iap.queryProductDetails({id});
    if (r.productDetails.isEmpty) return null;
    final ProductDetails p = r.productDetails.first;
    _products[id] = p;
    return StoreProduct(
      id: p.id,
      price: p.price,
      rawPrice: p.rawPrice,
      currency: p.currencyCode,
    );
  }

  @override
  Stream<List<StorePurchase>> get purchaseUpdates => _iap.purchaseStream.map(
    (list) => [
      for (final PurchaseDetails p in list)
        StorePurchase(
          productId: p.productID,
          status: switch (p.status) {
            PurchaseStatus.pending => StorePurchaseStatus.pending,
            PurchaseStatus.purchased => StorePurchaseStatus.purchased,
            PurchaseStatus.restored => StorePurchaseStatus.restored,
            PurchaseStatus.error => StorePurchaseStatus.error,
            PurchaseStatus.canceled => StorePurchaseStatus.canceled,
          },
          needsCompletion: p.pendingCompletePurchase,
          raw: p,
        ),
    ],
  );

  @override
  Future<void> buyNonConsumable(String productId) async {
    final ProductDetails? p =
        _products[productId] ??
        (await _iap.queryProductDetails({
          productId,
        })).productDetails.firstOrNull;
    if (p == null) throw StateError('Product $productId not found');
    await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: p),
    );
  }

  @override
  Future<void> restore() => _iap.restorePurchases();

  @override
  Future<void> complete(StorePurchase purchase) async {
    final Object? raw = purchase.raw;
    if (raw is PurchaseDetails) await _iap.completePurchase(raw);
  }
}
