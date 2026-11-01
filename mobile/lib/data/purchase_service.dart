import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';

/// Do'kondagi Pro taklifi (narx do'kondan, mahalliy valyutada).
class ProOffer {
  const ProOffer({required this.id, required this.price, required this.yearly, this.native});
  final String id;
  final String price;
  final bool yearly;
  final Object? native; // RevenueCat Package
}

/// Obuna xizmati. Kalit berilmagan bo'lsa (masalan, testlarda) "mavjud emas".
abstract class PurchaseService {
  bool get isAvailable;
  Future<void> logIn(String uid);
  Future<void> logOut();
  Future<List<ProOffer>> offers();

  /// true: xarid muvaffaqiyatli va Pro faol. false: bekor qilindi.
  Future<bool> buy(ProOffer offer);

  /// true: tiklangandan keyin Pro faol.
  Future<bool> restore();
  Future<bool> hasPro();
}

class UnavailablePurchaseService implements PurchaseService {
  const UnavailablePurchaseService();
  @override
  bool get isAvailable => false;
  @override
  Future<void> logIn(String uid) async {}
  @override
  Future<void> logOut() async {}
  @override
  Future<List<ProOffer>> offers() async => const [];
  @override
  Future<bool> buy(ProOffer offer) async => false;
  @override
  Future<bool> restore() async => false;
  @override
  Future<bool> hasPro() async => false;
}

/// RevenueCat: ommaviy SDK kalitlari `--dart-define=RC_APPLE_KEY=... / RC_GOOGLE_KEY=...` (maxfiy emas).
class RevenueCatPurchaseService implements PurchaseService {
  RevenueCatPurchaseService._();
  static const entitlement = 'pro';
  static const _apple = String.fromEnvironment('RC_APPLE_KEY');
  static const _google = String.fromEnvironment('RC_GOOGLE_KEY');

  static Future<PurchaseService> create() async {
    if (kIsWeb) return const UnavailablePurchaseService();
    final key = Platform.isIOS ? _apple : _google;
    if (key.isEmpty) return const UnavailablePurchaseService();
    try {
      await Purchases.configure(PurchasesConfiguration(key));
      return RevenueCatPurchaseService._();
    } catch (_) {
      return const UnavailablePurchaseService();
    }
  }

  @override
  bool get isAvailable => true;

  @override
  Future<void> logIn(String uid) async {
    try {
      await Purchases.logIn(uid);
    } catch (_) {}
  }

  @override
  Future<void> logOut() async {
    try {
      if (!await Purchases.isAnonymous) await Purchases.logOut();
    } catch (_) {}
  }

  @override
  Future<List<ProOffer>> offers() async {
    try {
      final o = (await Purchases.getOfferings()).current;
      if (o == null) return const [];
      return [
        for (final p in o.availablePackages)
          if (p.packageType == PackageType.monthly || p.packageType == PackageType.annual)
            ProOffer(id: p.identifier, price: p.storeProduct.priceString, yearly: p.packageType == PackageType.annual, native: p),
      ];
    } catch (_) {
      return const [];
    }
  }

  bool _active(CustomerInfo i) => i.entitlements.active.containsKey(entitlement);

  @override
  Future<bool> buy(ProOffer offer) async {
    try {
      final r = await Purchases.purchase(PurchaseParams.package(offer.native! as Package));
      return _active(r.customerInfo);
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) == PurchasesErrorCode.purchaseCancelledError) return false;
      rethrow;
    }
  }

  @override
  Future<bool> restore() async => _active(await Purchases.restorePurchases());

  @override
  Future<bool> hasPro() async {
    try {
      return _active(await Purchases.getCustomerInfo());
    } catch (_) {
      return false;
    }
  }
}
