import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:altin_takip/features/currencies/domain/currency_history.dart';
import 'package:equatable/equatable.dart';

class CurrencyHistoryData extends Equatable {
  final List<CurrencyHistory> history;
  final List<Asset> userAssets;

  const CurrencyHistoryData({required this.history, required this.userAssets});

  @override
  List<Object?> get props => [history, userAssets];
}
