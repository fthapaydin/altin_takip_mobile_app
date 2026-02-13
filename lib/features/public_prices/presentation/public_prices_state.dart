import 'package:equatable/equatable.dart';
import 'package:altin_takip/features/public_prices/domain/public_prices_data.dart';

/// Base state for public prices
sealed class PublicPricesState extends Equatable {
  const PublicPricesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PublicPricesInitial extends PublicPricesState {
  const PublicPricesInitial();
}

/// Loading state
class PublicPricesLoading extends PublicPricesState {
  const PublicPricesLoading();
}

/// Loaded state with data
class PublicPricesLoaded extends PublicPricesState {
  final PublicPricesData data;

  const PublicPricesLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

/// Error state
class PublicPricesError extends PublicPricesState {
  final String message;

  const PublicPricesError(this.message);

  @override
  List<Object?> get props => [message];
}
