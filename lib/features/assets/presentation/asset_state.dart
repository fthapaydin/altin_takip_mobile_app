import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:altin_takip/features/assets/domain/pagination.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';
import 'package:altin_takip/features/dashboard/domain/dashboard_data.dart';

sealed class AssetState {
  const AssetState();
}

class AssetInitial extends AssetState {
  const AssetInitial();
}

class AssetLoading extends AssetState {
  const AssetLoading();
}

class AssetLoaded extends AssetState {
  final List<Asset> assets;
  final Pagination pagination;
  final List<Currency> currencies;
  final bool isLoadingMore;
  final bool hasMore;
  final bool isRefreshing;
  final String? actionError; // For one-off errors like delete failure
  final DashboardData? dashboardData; // Dashboard summary and chart data

  const AssetLoaded({
    required this.assets,
    required this.pagination,
    required this.currencies,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.hasMore = true,
    this.actionError,
    this.dashboardData,
  });

  AssetLoaded copyWith({
    List<Asset>? assets,
    Pagination? pagination,
    List<Currency>? currencies,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? hasMore,
    String? actionError,
    DashboardData? dashboardData,
  }) {
    return AssetLoaded(
      assets: assets ?? this.assets,
      pagination: pagination ?? this.pagination,
      currencies: currencies ?? this.currencies,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasMore: hasMore ?? this.hasMore,
      actionError:
          actionError, // Don't copy actionError by default unless specified
      dashboardData: dashboardData ?? this.dashboardData,
    );
  }
}

class AssetError extends AssetState {
  final String message;
  const AssetError(this.message);
}
