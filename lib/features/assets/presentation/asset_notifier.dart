import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/core/error/failures.dart';
import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:altin_takip/features/assets/domain/asset_repository.dart';
import 'package:altin_takip/features/assets/domain/pagination.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';
import 'package:altin_takip/features/currencies/domain/currency_repository.dart';
import 'package:altin_takip/features/auth/presentation/auth_notifier.dart';
import 'package:altin_takip/features/dashboard/domain/dashboard_data.dart';
import 'package:altin_takip/features/dashboard/domain/dashboard_repository.dart';

final assetProvider = NotifierProvider<AssetNotifier, AssetState>(
  AssetNotifier.new,
);

class AssetNotifier extends Notifier<AssetState> {
  late final AssetRepository _assetRepository;
  late final CurrencyRepository _currencyRepository;
  late final DashboardRepository _dashboardRepository;

  @override
  AssetState build() {
    _assetRepository = sl<AssetRepository>();
    _currencyRepository = sl<CurrencyRepository>();
    _dashboardRepository = sl<DashboardRepository>();
    return const AssetInitial();
  }

  Future<void> loadDashboard({bool refresh = false}) async {
    final currentState = state;

    // Allow concurrent loadDashboard calls to proceed to ensure we get data
    // but preventing typical spamming if we are already fetching dashboard explicitly?
    // For now, we prioritize getting data over preventing duplicate requests.

    // Only show full loading if we have no data or it's an explicit forced refresh
    if (currentState is! AssetLoaded) {
      state = const AssetLoading();
    } else if (refresh) {
      // Set refreshing flag in state for reactivity
      state = currentState.copyWith(isRefreshing: true);
    }

    try {
      // Fetch all data concurrently
      final results = await Future.wait([
        _assetRepository.getAssets(),
        _currencyRepository.getCurrencies(),
        _dashboardRepository.getDashboardData(),
      ]);

      final assetsResult =
          results[0] as Either<Failure, (List<Asset>, Pagination)>;
      final currenciesResult = results[1] as Either<Failure, List<Currency>>;
      final dashboardResult = results[2] as Either<Failure, DashboardData>;

      currenciesResult.fold(
        (currencyFailure) {
          state = AssetError(currencyFailure.message);
        },
        (currencies) {
          assetsResult.fold(
            (assetFailure) {
              if (assetFailure is EncryptionRequiredFailure) {
                ref.read(authProvider.notifier).forceEncryptionRequired();
              }

              state = AssetLoaded(
                assets: [],
                pagination: const Pagination(
                  currentPage: 1,
                  lastPage: 1,
                  perPage: 0,
                  total: 0,
                ),
                currencies: currencies,
                hasMore: false,
                isRefreshing: false,
                dashboardData: dashboardResult.fold((_) {
                  // Preserve existing data on failure if available
                  final current = state; // Use latest state
                  return current is AssetLoaded ? current.dashboardData : null;
                }, (data) => data),
              );
            },
            (data) {
              final (assets, pagination) = data;
              state = AssetLoaded(
                assets: assets,
                pagination: pagination,
                currencies: currencies,
                hasMore: pagination.currentPage < pagination.lastPage,
                isRefreshing: false,
                dashboardData: dashboardResult.fold((_) {
                  // Preserve existing data on failure if available
                  final current = state; // Use latest state
                  return current is AssetLoaded ? current.dashboardData : null;
                }, (data) => data),
              );
            },
          );
        },
      );
    } catch (e) {
      if (currentState is AssetLoaded) {
        state = currentState.copyWith(isRefreshing: false);
      } else {
        state = AssetError(e.toString());
      }
    }
  }

  Future<void> loadAllAssets({bool refresh = false}) async {
    // If it's a refresh during dashboard view, loadDashboard is better as it's a superset
    if (refresh) {
      // However, loadDashboard is heavier. If we only need assets...
      // But preserving dashboardData is key.
      // Let's stick to specific implementation but careful with state.
    }

    final currentState = state;
    if (currentState is AssetLoaded && currentState.isRefreshing) return;

    if (currentState is! AssetLoaded) {
      state = const AssetLoading();
    } else {
      state = currentState.copyWith(isRefreshing: true);
    }

    try {
      final assetsResult = await _assetRepository.getAssets(page: 1);
      final currenciesResult = await _currencyRepository.getCurrencies();

      assetsResult.fold((failure) => state = AssetError(failure.message), (
        data,
      ) {
        final (assets, pagination) = data;
        currenciesResult.fold(
          (failure) => state = AssetError(failure.message),
          (currencies) {
            // Use latest state to preserve dashboardData
            final current = state;
            state = AssetLoaded(
              assets: assets,
              pagination: pagination,
              currencies: currencies,
              hasMore: pagination.currentPage < pagination.lastPage,
              isRefreshing: false,
              dashboardData: current is AssetLoaded
                  ? current.dashboardData
                  : null,
            );
          },
        );
      });
    } catch (e) {
      if (currentState is AssetLoaded) {
        state = currentState.copyWith(isRefreshing: false);
      } else {
        state = AssetError(e.toString());
      }
    }
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
