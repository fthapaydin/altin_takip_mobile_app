import 'package:fpdart/fpdart.dart';
import 'package:altin_takip/core/error/failures.dart';
import 'package:altin_takip/core/network/dio_client.dart';
import 'package:altin_takip/core/network/network_exception_handler.dart';
import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:altin_takip/features/assets/data/asset_dto.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';
import 'package:altin_takip/features/currencies/domain/currency_repository.dart';
import 'package:altin_takip/features/currencies/data/currency_history_dto.dart';
import 'package:altin_takip/features/currencies/domain/currency_history_data.dart';

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

  @override
  Future<Either<Failure, CurrencyHistoryData>> getHistory(
    String currencyId,
    String range,
  ) async {
    try {
      print('DEBUG: Fetching history for $currencyId range $range');
      final response = await _dioClient.dio.get(
        '/currencies/$currencyId/history',
        queryParameters: {'range': range},
      );

      print('DEBUG: History response status: ${response.statusCode}');

      final Map<String, dynamic> data = response.data;

      final List historyList = data['history'] as List? ?? [];
      final List userAssetsList = data['user_assets'] as List? ?? [];

      print('DEBUG: History data length: ${historyList.length}');
      print('DEBUG: User assets length: ${userAssetsList.length}');

      final history = historyList.map((json) {
        try {
          return CurrencyHistoryDto.fromJson(json);
        } catch (e) {
          print('DEBUG: Error parsing history item: $e');
          rethrow;
        }
      }).toList();

      final userAssets = userAssetsList.map((json) {
        try {
          // The API returns a simplified asset object without ID or currency_id
          // We need to construct it manually.

          // Parse date: "30.01.2026"
          DateTime parsedDate;
          try {
            final dateStr = json['date'] as String;
            final parts = dateStr.split('.');
            if (parts.length == 3) {
              parsedDate = DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );
            } else {
              parsedDate = DateTime.now(); // Fallback
            }
          } catch (_) {
            parsedDate = DateTime.now();
          }

          return Asset(
            id: 0, // Mock ID as it's not provided
            currencyId: int.tryParse(currencyId) ?? 0,
            type: json['type'] ?? 'buy',
            amount: double.tryParse(json['amount'].toString()) ?? 0.0,
            price: double.tryParse(json['price'].toString()) ?? 0.0,
            date: parsedDate,
          );
        } catch (e) {
          print('DEBUG: Error parsing asset item: $e');
          rethrow;
        }
      }).toList();

      return Right(
        CurrencyHistoryData(history: history, userAssets: userAssets),
      );
    } catch (e) {
      print('DEBUG: Repository Error: $e');
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }
}
