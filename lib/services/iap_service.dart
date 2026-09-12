import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:planedriver_flame/game/models/vehicle.dart';
import 'package:planedriver_flame/services/save_service.dart';

class IAPService {
  IAPService._();

  static final IAPService instance = IAPService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  static List<String> get planeProductIds =>
      Vehicle.all.map((v) => v.productId).toList();

  static int planeIdFromProductId(String productId) {
    return Vehicle.all.firstWhere((v) => v.productId == productId).id;
  }

  Future<bool> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) return false;

    _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
    );

    await loadProducts();
    return true;
  }

  Future<List<ProductDetails>> loadProducts() async {
    final response = await _iap.queryProductDetails(planeProductIds.toSet());
    _products = response.productDetails;
    return _products;
  }

  List<ProductDetails> get products => List.unmodifiable(_products);

  ProductDetails? productForPlane(int planeId) {
    final productId = Vehicle.byId(planeId).productId;
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }

  String priceForPlane(int planeId) {
    final product = productForPlane(planeId);
    return product?.price ?? '0.99 USD';
  }

  Future<bool> purchasePlane(int planeId) async {
    final vehicle = Vehicle.byId(planeId);

    if (vehicle.isFree || SaveService.instance.isPlaneOwned(planeId)) {
      return true;
    }

    final product = productForPlane(planeId);
    if (product != null) {
      final purchaseParam = PurchaseParam(productDetails: product);
      return _iap.buyNonConsumable(purchaseParam: purchaseParam);
    }

    return fakePurchase(planeId);
  }

  Future<bool> restorePurchases() async {
    await _iap.restorePurchases();

    await SaveService.instance.restoreAllPlanes();
    return true;
  }

  Future<bool> fakePurchase(int planeId) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await SaveService.instance.addOwnedPlaneId(planeId);
    return true;
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        final planeId = planeIdFromProductId(purchase.productID);
        await SaveService.instance.addOwnedPlaneId(planeId);
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
