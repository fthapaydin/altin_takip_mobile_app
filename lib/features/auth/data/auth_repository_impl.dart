import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:altin_takip/core/error/failures.dart';
import 'package:altin_takip/core/network/dio_client.dart';
import 'package:altin_takip/core/network/network_exception_handler.dart';
import 'package:altin_takip/features/auth/data/user_dto.dart';
import 'package:altin_takip/features/auth/domain/auth_repository.dart';
import 'package:altin_takip/features/auth/domain/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dioClient;

  AuthRepositoryImpl(this._dioClient);

  @override
  Future<Either<Failure, (User, String)>> login({
    required String email,
    required String password,
    String? oneSignalId,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'onesignal_id': oneSignalId ?? '',
        },
      );

      final user = UserDto.fromJson(response.data['user']);
      final token = response.data['token'];

      return Right((user, token));
    } catch (e) {
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Unit>> forgotPassword({required String email}) async {
    try {
      await _dioClient.dio.post('/auth/forgot-password', data: {'email': email});
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String verificationCode,
    required String password,
  }) async {
    try {
      await _dioClient.dio.post(
        '/auth/reset-password',
        data: {
          'verification_code': verificationCode,
          'password': password,
          'password_confirmation': password,
        },
      );
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, (User, String)>> register({
    required String name,
    required String surname,
    required String email,
    required String password,
    String? oneSignalId,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/register',
        data: {
          'name': name,
          'surname': surname,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'onesignal_id': oneSignalId ?? '',
        },
      );

      final user = UserDto.fromJson(response.data['user']);
      final token = response.data['token'];

      return Right((user, token));
    } catch (e) {
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dioClient.dio.post(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPassword,
        },
      );
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount({
    required String password,
  }) async {
    try {
      await _dioClient.dio.delete(
        '/auth/delete-account',
        data: {'password': password},
      );
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleEncryption({
    required bool status,
    required String password,
  }) async {
    try {
      await _dioClient.dio.post(
        '/encryption/toggle',
        data: {'status': status, 'password': password},
      );
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyEncryptionKey(String key) async {
    try {
      await _dioClient.dio.get(
        '/assets',
        options: Options(headers: {'X-Encryption-Key': key}),
      );
      return const Right(true);
    } catch (e) {
      if (e is DioException &&
          (e.response?.statusCode == 400 || e.response?.statusCode == 401)) {
        return Left(AuthFailure(NetworkExceptionHandler.getErrorMessage(e)));
      }
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, User>> getUser() async {
    try {
      await _dioClient.dio.get('/currencies');
      return Left(ServerFailure('User data should be retrieved from storage.'));
    } catch (e) {
      if (e is DioException) {
        return Left(AuthFailure(NetworkExceptionHandler.getErrorMessage(e)));
      }
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }
}
