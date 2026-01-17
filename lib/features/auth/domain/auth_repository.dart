import 'package:fpdart/fpdart.dart';
import 'package:altin_takip/core/error/failures.dart';
import 'package:altin_takip/features/auth/domain/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, (User, String)>> register({
    required String name,
    required String surname,
    required String email,
    required String password,
    String? oneSignalId,
  });

  Future<Either<Failure, (User, String)>> login({
    required String email,
    required String password,
    String? oneSignalId,
  });

  Future<Either<Failure, Unit>> forgotPassword({required String email});

  Future<Either<Failure, Unit>> resetPassword({
    required String verificationCode,
    required String password,
  });

  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, Unit>> deleteAccount({required String password});

  Future<Either<Failure, Unit>> toggleEncryption({
    required bool status,
    required String password,
  });
  Future<Either<Failure, bool>> verifyEncryptionKey(String key);
  Future<Either<Failure, User>> getUser();
}
