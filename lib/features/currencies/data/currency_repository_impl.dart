import 'package:fpdart/fpdart.dart';
import 'package:altin_takip/core/error/failures.dart';
import 'package:altin_takip/core/network/dio_client.dart';
import 'package:altin_takip/core/network/network_exception_handler.dart';
import 'package:altin_takip/features/assets/data/asset_dto.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';
import 'package:altin_takip/features/currencies/domain/currency_repository.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final DioClient _dioClient;

  CurrencyRepositoryImpl(this._dioClient);

  @override
  Future<Either<Failure, List<Currency>>> getCurrencies() async {
    try {
      final response = await _dioClient.dio.get('/currencies');

      final dynamic responseData = response.data;
      List data;

      if (responseData is List) {
        data = responseData;
      } else if (responseData is Map<String, dynamic> &&
          responseData.containsKey('data')) {
        data = responseData['data'] is List ? responseData['data'] : [];
      } else {
        data = [];
      }

      final currencies = data
          .map<Currency>((json) => CurrencyDto.fromJson(json))
          .toList();

      return Right(currencies);
    } catch (e) {
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }
}
