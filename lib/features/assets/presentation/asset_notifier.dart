import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/features/assets/domain/asset_repository.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/currencies/domain/currency_repository.dart';

final assetProvider = NotifierProvider<AssetNotifier, AssetState>(
  AssetNotifier.new,
);

class AssetNotifier extends Notifier<AssetState> {
  late final AssetRepository _assetRepository;
  late final CurrencyRepository _currencyRepository;

  @override
  AssetState build() {
    _assetRepository = sl<AssetRepository>();
    _currencyRepository = sl<CurrencyRepository>();
    return const AssetInitial();
  }

  Future<void> loadDashboard() async {
    state = const AssetLoading();

    final assetsResult = await _assetRepository.getAssets();
    final currenciesResult = await _currencyRepository.getCurrencies();

    assetsResult.fold((failure) => state = AssetError(failure.message), (data) {
      final (assets, pagination) = data;
      currenciesResult.fold(
        (failure) => state = AssetError(failure.message),
        (currencies) => state = AssetLoaded(
          assets: assets,
          pagination: pagination,
          currencies: currencies,
          hasMore: pagination.currentPage < pagination.lastPage,
        ),
      );
    });
  }

  Future<void> loadAllAssets({bool refresh = false}) async {
    if (refresh) {
      state = const AssetLoading();
    }

    final assetsResult = await _assetRepository.getAssets(page: 1);
    final currenciesResult = await _currencyRepository.getCurrencies();

    assetsResult.fold((failure) => state = AssetError(failure.message), (data) {
      final (assets, pagination) = data;
      currenciesResult.fold(
        (failure) => state = AssetError(failure.message),
        (currencies) => state = AssetLoaded(
          assets: assets,
          pagination: pagination,
          currencies: currencies,
          hasMore: pagination.currentPage < pagination.lastPage,
        ),
      );
    });
  }

  Future<void> loadMoreAssets() async {
    final currentState = state;
    if (currentState is! AssetLoaded) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    state = currentState.copyWith(isLoadingMore: true);

    final nextPage = currentState.pagination.currentPage + 1;
    final result = await _assetRepository.getAssets(page: nextPage);

    result.fold(
      (failure) => state = currentState.copyWith(isLoadingMore: false),
      (data) {
        final (newAssets, pagination) = data;
        final allAssets = [...currentState.assets, ...newAssets];
        state = currentState.copyWith(
          assets: allAssets,
          pagination: pagination,
          isLoadingMore: false,
          hasMore: pagination.currentPage < pagination.lastPage,
        );
      },
    );
  }

  Future<bool> addAsset({
    required int currencyId,
    required double amount,
    required double price,
    required DateTime date,
    required bool isBuy,
    String? place,
    String? note,
  }) async {
    final currentState = state;
    final result = isBuy
        ? await _assetRepository.buyAsset(
            currencyId: currencyId,
            amount: amount,
            price: price,
            date: date,
            place: place,
            note: note,
          )
        : await _assetRepository.sellAsset(
            currencyId: currencyId,
            amount: amount,
            price: price,
            date: date,
            place: place,
            note: note,
          );

    return result.fold(
      (failure) {
        if (currentState is AssetLoaded) {
          state = currentState.copyWith(actionError: failure.message);
        } else {
          state = AssetError(failure.message);
        }
        return false;
      },
      (_) {
        loadDashboard();
        return true;
      },
    );
  }

  Future<bool> deleteAsset(int id) async {
    final currentState = state;
    final result = await _assetRepository.deleteAsset(id);
    return result.fold(
      (failure) {
        if (currentState is AssetLoaded) {
          state = currentState.copyWith(actionError: failure.message);
        } else {
          state = AssetError(failure.message);
        }
        return false;
      },
      (_) {
        loadAllAssets(refresh: true);
        return true;
      },
    );
  }

  Future<void> sellAssetById({
    required int currencyId,
    required double amount,
    required double price,
  }) async {
    final result = await _assetRepository.sellAsset(
      currencyId: currencyId,
      amount: amount,
      price: price,
      date: DateTime.now(),
    );
    result.fold(
      (failure) => state = AssetError(failure.message),
      (_) => loadAllAssets(refresh: true),
    );
  }
}
