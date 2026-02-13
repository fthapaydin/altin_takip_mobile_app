import 'package:fpdart/fpdart.dart';
import 'package:altin_takip/core/error/failures.dart';
import 'package:altin_takip/core/network/public_dio_client.dart';
import 'package:altin_takip/core/network/network_exception_handler.dart';
import 'package:altin_takip/features/public_prices/domain/public_prices_repository.dart';
import 'package:altin_takip/features/public_prices/domain/public_prices_data.dart';
import 'package:altin_takip/features/public_prices/data/public_price_dto.dart';

class PublicPricesRepositoryImpl implements PublicPricesRepository {
  final PublicDioClient _publicDioClient;

  PublicPricesRepositoryImpl(this._publicDioClient);

  @override
  Future<Either<Failure, PublicPricesData>> getPublicPrices() async {
    try {
      final response = await _publicDioClient.dio.get('today.json');

      if (response.statusCode == 200 && response.data != null) {
        final pricesData = PublicPricesDataDto.fromJson(
          response.data as Map<String, dynamic>,
        );
        return Right(pricesData);
      }

      return Left(ServerFailure('Fiyat verileri yüklenemedi'));
    } catch (e) {
      final errorMessage = NetworkExceptionHandler.getErrorMessage(e);
      return Left(ServerFailure(errorMessage));
    }
  }
}
