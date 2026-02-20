import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:altin_takip/core/error/failures.dart';

/// Wraps the Google Sign-In SDK.
///
/// Returns the authenticated Google account or a [Failure].
class GoogleSignInService {
  static const _iosClientId =
      '808192730816-glecgeop4cn38deftt3989hk1sl8t7sq.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn;

  GoogleSignInService() {
    _googleSignIn = GoogleSignIn(
      scopes: ['email'],
      clientId: Platform.isIOS ? _iosClientId : null,
    );
  }

  Future<Either<Failure, GoogleSignInAccount>> signIn() async {
    try {
      // Sign out first to always show account picker
      await _googleSignIn.signOut();

      final account = await _googleSignIn.signIn();
      if (account == null) {
        return const Left(AuthFailure('Google ile giriş iptal edildi.'));
      }
      return Right(account);
    } catch (e) {
      return Left(
        ServerFailure('Google ile giriş yapılırken bir hata oluştu: $e'),
      );
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
