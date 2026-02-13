import 'package:equatable/equatable.dart';

/// Represents a single price item from the public API
class PublicPrice extends Equatable {
  final String code;
  final String name;
  final String type; // "Döviz" or "Altın"
  final String buyPrice;
  final String sellPrice;
  final String change;

  const PublicPrice({
    required this.code,
    required this.name,
    required this.type,
    required this.buyPrice,
    required this.sellPrice,
    required this.change,
  });

  @override
  List<Object?> get props => [code, name, type, buyPrice, sellPrice, change];
}
