import 'package:equatable/equatable.dart';
import 'package:altin_takip/features/public_prices/domain/public_price.dart';

/// Contains all public prices data separated by type
class PublicPricesData extends Equatable {
  final String updateDate;
  final List<PublicPrice> currencies;
  final List<PublicPrice> goldPrices;

  const PublicPricesData({
    required this.updateDate,
    required this.currencies,
    required this.goldPrices,
  });

  @override
  List<Object?> get props => [updateDate, currencies, goldPrices];
}
