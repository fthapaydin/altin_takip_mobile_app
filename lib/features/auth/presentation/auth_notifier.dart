import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/core/storage/storage_service.dart';
import 'package:altin_takip/features/auth/domain/auth_repository.dart';
import 'package:altin_takip/features/auth/presentation/auth_state.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;
  late final StorageService _storage;

  @override
  AuthState build() {
    _repository = sl<AuthRepository>();
    _storage = sl<StorageService>();

    // Check auth status on startup
    Future.microtask(() => checkAuthStatus());

    return const AuthInitial();
  }

  Future<void> checkAuthStatus() async {
    final token = await _storage.getToken();
    final user = await _storage.getUser();
    final encryptionKey = await _storage.getEncryptionKey();

    if (token != null && user != null) {
      if (user.isEncrypted && encryptionKey == null) {
        state = AuthEncryptionRequired(user);
      } else {
        state = AuthAuthenticated(user);
      }
    } else {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    final result = await _repository.login(email: email, password: password);

    result.fold(
      (failure) => state = AuthUnauthenticated(error: failure.message),
      (data) async {
        final (user, token) = data;
        await _storage.saveToken(token);
        await _storage.saveUser(user);
        if (user.isEncrypted) {
          state = AuthEncryptionRequired(user);
        } else {
          state = AuthAuthenticated(user);
        }
      },
    );
  }

  Future<void> forgotPassword(String email) async {
    state = const AuthLoading();
    final result = await _repository.forgotPassword(email: email);

    result.fold(
      (failure) => state = AuthUnauthenticated(error: failure.message),
      (_) => state = const AuthUnauthenticated(), // Success, allow navigation
    );
  }

  Future<void> resetPassword(String verificationCode, String password) async {
    state = const AuthLoading();
    final result = await _repository.resetPassword(
      verificationCode: verificationCode,
      password: password,
    );

    result.fold(
      (failure) => state = AuthUnauthenticated(error: failure.message),
      (_) => state = const AuthUnauthenticated(), // Success, allow navigation
    );
  }

  Future<void> register(
    String name,
    String surname,
    String email,
    String password,
  ) async {
    state = const AuthLoading();
    final result = await _repository.register(
      name: name,
      surname: surname,
      email: email,
      password: password,
    );

    result.fold(
      (failure) => state = AuthUnauthenticated(error: failure.message),
      (data) async {
        final (user, token) = data;
        await _storage.saveToken(token);
        await _storage.saveUser(user);
        if (user.isEncrypted) {
          state = AuthEncryptionRequired(user);
        } else {
          state = AuthAuthenticated(user);
        }
      },
    );
  }

  Future<void> setEncryptionKey(String key) async {
    final currentState = state;
    if (currentState is AuthEncryptionRequired) {
      final user = currentState.user;
      state = AuthEncryptionRequired(user, isLoading: true);

      final result = await _repository.verifyEncryptionKey(key);

      result.fold(
        (failure) =>
            state = AuthEncryptionRequired(user, error: failure.message),
        (_) async {
          await _storage.saveEncryptionKey(key);
          state = AuthAuthenticated(user);
        },
      );

    }
  }

  void forceEncryptionRequired() {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      // Preserve the user but switch state
      state = AuthEncryptionRequired(currentState.user);
    } else if (currentState is AuthEncryptionRequired) {
       // Already in state
    } else {
       // If no user is loaded, we can't switch to EncryptionRequired(User), 
       // but likely we are authenticated if we got this error.
       // We'll rely on checkAuthStatus or re-login if totally lost.
       checkAuthStatus();
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    state = const AuthUnauthenticated();
  }
}
