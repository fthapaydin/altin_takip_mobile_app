import 'package:altin_takip/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

import 'package:purchases_flutter/object_wrappers.dart';

abstract class PurchaseRepository {
  /// Initializes the RevenueCat SDK.
  Future<void> init();

  /// Gets the current customer info (subscription status).
  Future<Either<Failure, bool>> getPremiumStatus();

  /// Fetches the available offerings (products) to display on the paywall.
  Future<Either<Failure, List<Package>>> getOfferings();

  /// Purchases a specific package.
  Future<Either<Failure, bool>> purchasePackage(Package package);

  /// Restores purchases.
  Future<Either<Failure, bool>> restorePurchases();

  /// Presents the native Paywall UI.
  /// Returns [true] if a purchase occurred, [false] otherwise.
  Future<void> presentPaywall({bool displayCloseButton = true});

  /// Presents the native Customer Center UI.
  Future<void> presentCustomerCenter();
}
