import 'package:altin_takip/features/auth/domain/user.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthEncryptionRequired extends AuthState {
  final User user;
  final String? error;
  final bool isLoading;
  const AuthEncryptionRequired(this.user, {this.error, this.isLoading = false});
}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  final String? error;
  const AuthUnauthenticated({this.error});
}
