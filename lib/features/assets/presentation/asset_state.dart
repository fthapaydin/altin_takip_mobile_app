import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:altin_takip/features/assets/domain/pagination.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';

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
  final String? actionError; // For one-off errors like delete failure

  const AssetLoaded({
    required this.assets,
    required this.pagination,
    required this.currencies,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.actionError,
  });

  AssetLoaded copyWith({
    List<Asset>? assets,
    Pagination? pagination,
    List<Currency>? currencies,
    bool? isLoadingMore,
    bool? hasMore,
    String? actionError,
  }) {
    return AssetLoaded(
      assets: assets ?? this.assets,
      pagination: pagination ?? this.pagination,
      currencies: currencies ?? this.currencies,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      actionError:
          actionError, // Don't copy actionError by default unless specified
    );
  }
}

class AssetError extends AssetState {
  final String message;
  const AssetError(this.message);
}
