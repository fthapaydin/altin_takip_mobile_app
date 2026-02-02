import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/features/subscription/domain/purchase_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/object_wrappers.dart';

// State definition
sealed class SubscriptionState {
  const SubscriptionState();
}

class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

class SubscriptionLoaded extends SubscriptionState {
  final bool isPremium;
  final List<Package> offerings;
  final String? error;

  const SubscriptionLoaded({
    required this.isPremium,
    this.offerings = const [],
    this.error,
  });

  SubscriptionLoaded copyWith({
    bool? isPremium,
    List<Package>? offerings,
    String? error,
  }) {
    return SubscriptionLoaded(
      isPremium: isPremium ?? this.isPremium,
      offerings: offerings ?? this.offerings,
      error: error,
    );
  }
}

// Notifier
class SubscriptionNotifier extends Notifier<SubscriptionState> {
  late final PurchaseRepository _repository;

  @override
  SubscriptionState build() {
    _repository = sl<PurchaseRepository>();
    _init();
    return const SubscriptionLoading();
  }

  Future<void> _init() async {
    // 1. Init SDK
    await _repository.init();

    // 2. Check status
    final statusResult = await _repository.getPremiumStatus();
    final isPremium = statusResult.fold((l) => false, (r) => r);

    // 3. Get Offerings
    final offeringsResult = await _repository.getOfferings();
    final offerings = offeringsResult.fold((l) => <Package>[], (r) => r);

    state = SubscriptionLoaded(
      isPremium: isPremium,
      offerings: offerings.cast<Package>(),
    );
  }

  Future<void> purchasePackage(Package package) async {
    final currentState = state;
    if (currentState is! SubscriptionLoaded) return;

    // Clear previous errors
    state = currentState.copyWith(error: null);

    final result = await _repository.purchasePackage(package);

    result.fold(
      (failure) {
        state = currentState.copyWith(error: failure.message);
      },
      (isPremium) {
        state = currentState.copyWith(isPremium: isPremium);
      },
    );
  }

  Future<void> restorePurchases() async {
    final currentState = state;
    if (currentState is! SubscriptionLoaded) return;

    final result = await _repository.restorePurchases();

    result.fold(
      (failure) {
        state = currentState.copyWith(error: failure.message);
      },
      (isPremium) {
        state = currentState.copyWith(isPremium: isPremium);
      },
    );
  }

  Future<void> showNativePaywall() async {
    await _repository.presentPaywall();
  }
}

// Provider
final subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
      SubscriptionNotifier.new,
    );
