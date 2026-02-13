import 'package:fpdart/fpdart.dart';
import 'package:altin_takip/core/error/failures.dart';
import 'package:altin_takip/features/public_prices/domain/public_prices_data.dart';

/// Repository interface for fetching public prices
abstract class PublicPricesRepository {
  Future<Either<Failure, PublicPricesData>> getPublicPrices();
}
