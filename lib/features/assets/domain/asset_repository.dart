import 'package:fpdart/fpdart.dart';
import 'package:altin_takip/core/error/failures.dart';
import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:altin_takip/features/assets/domain/pagination.dart';

abstract class AssetRepository {
  Future<Either<Failure, (List<Asset>, Pagination)>> getAssets({int page = 1});

  Future<Either<Failure, Asset>> buyAsset({
    required int currencyId,
    required double amount,
    required double price,
    required DateTime date,
    String? place,
    String? note,
  });

  Future<Either<Failure, Asset>> sellAsset({
    required int currencyId,
    required double amount,
    required double price,
    required DateTime date,
    String? place,
    String? note,
  });

  Future<Either<Failure, Unit>> deleteAsset(int id);
}
