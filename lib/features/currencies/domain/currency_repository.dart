import 'package:altin_takip/features/currencies/domain/currency_history_data.dart';
import 'package:fpdart/fpdart.dart';
import 'package:altin_takip/core/error/failures.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';

abstract class CurrencyRepository {
  Future<Either<Failure, List<Currency>>> getCurrencies();
  Future<Either<Failure, CurrencyHistoryData>> getHistory(
    String currencyId,
    String range,
  );
}
