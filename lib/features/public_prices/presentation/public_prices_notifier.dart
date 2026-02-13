import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/features/public_prices/domain/public_prices_repository.dart';
import 'package:altin_takip/features/public_prices/presentation/public_prices_state.dart';

class PublicPricesNotifier extends Notifier<PublicPricesState> {
  late PublicPricesRepository _repository;

  @override
  PublicPricesState build() {
    _repository = sl<PublicPricesRepository>();
    return const PublicPricesInitial();
  }

  Future<void> loadPrices({bool refresh = false}) async {
    if (!refresh && state is PublicPricesLoaded) {
      return; // Don't reload if already loaded
    }

    state = const PublicPricesLoading();

    final result = await _repository.getPublicPrices();

    result.fold(
      (failure) => state = PublicPricesError(failure.message),
      (data) => state = PublicPricesLoaded(data),
    );
  }
}
