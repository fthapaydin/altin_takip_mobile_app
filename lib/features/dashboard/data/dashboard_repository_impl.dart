import 'package:fpdart/fpdart.dart';
import 'package:altin_takip/core/error/failures.dart';
import 'package:altin_takip/core/network/dio_client.dart';
import 'package:altin_takip/core/network/network_exception_handler.dart';
import 'package:altin_takip/features/dashboard/domain/dashboard_repository.dart';
import 'package:altin_takip/features/dashboard/domain/dashboard_data.dart';
import 'package:altin_takip/features/dashboard/data/dashboard_dto.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DioClient _dioClient;

  DashboardRepositoryImpl(this._dioClient);

  @override
  Future<Either<Failure, DashboardData>> getDashboardData() async {
    try {
      final response = await _dioClient.dio.get('dashboard');

      if (response.statusCode == 200 && response.data != null) {
        final dashboardData = DashboardDataDto.fromJson(
          response.data as Map<String, dynamic>,
        );
        return Right(dashboardData);
      }

      return Left(ServerFailure('Dashboard data could not be loaded'));
    } catch (e) {
      final errorMessage = NetworkExceptionHandler.getErrorMessage(e);
      return Left(ServerFailure(errorMessage));
    }
  }
}
