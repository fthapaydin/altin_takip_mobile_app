import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:altin_takip/core/error/failures.dart';
import 'package:altin_takip/core/network/dio_client.dart';
import 'package:altin_takip/core/network/network_exception_handler.dart';
import 'package:altin_takip/features/assets/data/asset_dto.dart';
import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:altin_takip/features/assets/domain/asset_repository.dart';
import 'package:altin_takip/features/assets/domain/pagination.dart';

class PaginationDto extends Pagination {
  const PaginationDto({
    required super.currentPage,
    required super.lastPage,
    required super.perPage,
    required super.total,
  });

  factory PaginationDto.fromJson(Map<String, dynamic> json) {
    return PaginationDto(
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      perPage: json['per_page'],
      total: json['total'],
    );
  }
}

class AssetRepositoryImpl implements AssetRepository {
  final DioClient _dioClient;

  AssetRepositoryImpl(this._dioClient);

  @override
  Future<Either<Failure, (List<Asset>, Pagination)>> getAssets({
    int page = 1,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/assets',
        queryParameters: {'page': page},
      );

      final dynamic responseData = response.data;
      List data;
      Map<String, dynamic> paginationMap;

      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data') && responseData['data'] is List) {
          data = responseData['data'];
          paginationMap =
              responseData['pagination'] ?? responseData['meta'] ?? {};
        } else if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          // Some APIs wrap it like { "data": { "data": [...], "pagination": {...} } }
          final nestedData = responseData['data'];
          data = nestedData['data'] ?? [];
          paginationMap = nestedData['pagination'] ?? nestedData['meta'] ?? {};
        } else {
          data = [];
          paginationMap = {};
        }
      } else {
        data = [];
        paginationMap = {};
      }

      final assets = data
          .map<Asset>((json) => AssetDto.fromJson(json))
          .toList();
      final pagination = paginationMap.isNotEmpty
          ? PaginationDto.fromJson(paginationMap)
          : const Pagination(
              currentPage: 1,
              lastPage: 1,
              perPage: 15,
              total: 0,
            );

      return Right((assets, pagination));
    } catch (e) {
      if (e is DioException) {
        final message = NetworkExceptionHandler.getErrorMessage(e);
        // Check for specific backend message or status code indicating encryption is required
        if (e.response?.statusCode == 400 &&
            (message.contains('şifre') || message.contains('encryption') || message.contains('password'))) {
           return const Left(EncryptionRequiredFailure());
        }
      }
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Asset>> buyAsset({
    required int currencyId,
    required double amount,
    required double price,
    required DateTime date,
    String? place,
    String? note,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/assets',
        data: {
          'currency_id': currencyId,
          'type': 'buy',
          'amount': amount,
          'price': price,
          'date': _formatDate(date),
          'place': place,
          'note': note,
        },
      );

      return Right(AssetDto.fromJson(response.data['data']));
    } catch (e) {
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Asset>> sellAsset({
    required int currencyId,
    required double amount,
    required double price,
    required DateTime date,
    String? place,
    String? note,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/assets',
        data: {
          'currency_id': currencyId,
          'type': 'sell',
          'amount': amount,
          'price': price,
          'date': _formatDate(date),
          'place': place,
          'note': note,
        },
      );

      return Right(AssetDto.fromJson(response.data['data']));
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 422) {
        return Left(
          ValidationFailure(NetworkExceptionHandler.getErrorMessage(e)),
        );
      }
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAsset(int id) async {
    try {
      await _dioClient.dio.delete('/assets/$id');
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
