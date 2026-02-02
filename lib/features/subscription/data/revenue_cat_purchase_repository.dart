import 'package:altin_takip/core/error/failures.dart';
import 'package:altin_takip/features/subscription/domain/purchase_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class RevenueCatPurchaseRepository implements PurchaseRepository {
  // -----------------------------------------------------------------------
  // REVENUECAT CONFIGURATION
  // -----------------------------------------------------------------------
  // Get these keys from: https://app.revenuecat.com/ > Your App > API Keys
  // Keys usually start with 'appl_' (iOS) or 'goog_' (Android).
  //
  // NOTE: The 'test_' prefix in your current key suggests it might be a specific
  // test key. For production, ensure you use the Public App-Specific API Key.
  // RevenueCat automatically handles Sandbox vs Production environments based
  // on the app build (Debug/TestFlight = Sandbox, App Store = Production).
  static const _apiKeyIOS = 'appl_pwvefuSrPWEtGYciLhafuTINFjh';
  static const _apiKeyAndroid = 'test_gNGKHAtADSImJhxaUMYQaYjpmaI';
  static const _entitlementId = 'Biriktirerek Pro';

  @override
  Future<void> init() async {
    print('🚀 [RC] Initialization Started');
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_apiKeyAndroid);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_apiKeyIOS);
    }

    if (configuration != null) {
      await Purchases.configure(configuration);
      print(
        '✅ [RC] SDK Configured for Bundle ID: com.fatalsoft.altintakip.app',
      );
    }
  }

  @override
  Future<Either<Failure, bool>> getPremiumStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return Right(_checkEntitlement(customerInfo));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Package>>> getOfferings() async {
    print('🔍 [RC] Fetching Offerings...');
    try {
      final offerings = await Purchases.getOfferings();

      print('📦 [RC] Raw Offerings Map Keys: ${offerings.all.keys.toList()}');
      print('🎯 [RC] Current Offering ID: ${offerings.current?.identifier}');

      if (offerings.current != null) {
        print(
          '📦 [RC] Current Packages count: ${offerings.current!.availablePackages.length}',
        );
      }

      final current = offerings.current;

      if (current != null && current.availablePackages.isNotEmpty) {
        return Right(current.availablePackages);
      } else {
        print(
          '⚠️ [RC] No packages in current offering. Trying fallback: app_store_offers',
        );
        final myOffering = offerings.all['app_store_offers'];

        if (myOffering != null && myOffering.availablePackages.isNotEmpty) {
          print('✅ [RC] Found packages in app_store_offers fallback!');
          return Right(myOffering.availablePackages);
        }

        print('❌ [RC] No packages found in any offering.');
        return const Right([]);
      }
    } catch (e) {
      print('‼️ [RC] Offering Fetch Error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return Right(_checkEntitlement(customerInfo));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> purchasePackage(Package package) async {
    try {
      final purchaseResult = await Purchases.purchase(
        PurchaseParams.package(package),
      );
      return Right(_checkEntitlement(purchaseResult.customerInfo));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  bool _checkEntitlement(CustomerInfo customerInfo) {
    return customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
  }

  @override
  Future<void> presentPaywall({bool displayCloseButton = true}) async {
    // Note: 'purchases_ui_flutter' is needed for this.
    // Ensure the package is added to pubspec.yaml.
    await RevenueCatUI.presentPaywall(displayCloseButton: displayCloseButton);
  }

  @override
  Future<void> presentCustomerCenter() async {
    await RevenueCatUI.presentCustomerCenter();
  }
}
