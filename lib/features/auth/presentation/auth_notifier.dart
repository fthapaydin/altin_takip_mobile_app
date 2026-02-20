import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/core/storage/storage_service.dart';
import 'package:altin_takip/core/services/onesignal_service.dart';
import 'package:altin_takip/features/auth/domain/auth_repository.dart';
import 'package:altin_takip/features/auth/presentation/auth_state.dart';
import 'package:altin_takip/features/auth/data/google_sign_in_service.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;
  late final StorageService _storage;
  late final GoogleSignInService _googleSignIn;
  late final OneSignalService _oneSignal;

  @override
  AuthState build() {
    _repository = sl<AuthRepository>();
    _storage = sl<StorageService>();
    _googleSignIn = sl<GoogleSignInService>();
    _oneSignal = sl<OneSignalService>();

    // Check auth status on startup
    Future.microtask(() => checkAuthStatus());

    return const AuthInitial();
  }

  Future<void> checkAuthStatus() async {
    // Record start time to ensure splash screen shows for at least 2.5 seconds
    final stopwatch = Stopwatch()..start();

    final token = await _storage.getToken();
    final user = await _storage.getUser();
    final encryptionKey = await _storage.getEncryptionKey();

    if (token != null && user != null) {
      // Set external user ID for OneSignal targeting
      _oneSignal.setExternalUserId(user.id.toString());

      // Sync latest OneSignal ID with backend
      final oneSignalId = await _oneSignal.getOneSignalId();
      if (oneSignalId != null) {
        await _repository.updateOneSignalId(oneSignalId);
      }

      // Ensure minimum splash screen display time for animation & prefetch
      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < 2500) {
        await Future.delayed(Duration(milliseconds: 2500 - elapsed));
      }

      if (user.isEncrypted && encryptionKey == null) {
        state = AuthEncryptionRequired(user);
      } else {
        state = AuthAuthenticated(user);
      }
    } else {
      // Ensure minimum splash screen display time for unauthenticated as well
      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < 2500) {
        await Future.delayed(Duration(milliseconds: 2500 - elapsed));
      }

      state = const AuthUnauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    final subscriptionId = await _oneSignal.getOneSignalId();

    final result = await _repository.login(
      email: email,
      password: password,
      oneSignalId: subscriptionId,
    );

    switch (result) {
      case Left(value: final failure):
        state = AuthUnauthenticated(error: failure.message);
      case Right(value: final data):
        final (user, token) = data;
        await _storage.saveToken(token);
        await _storage.saveUser(user);
        _oneSignal.setExternalUserId(user.id.toString());
        if (user.isEncrypted) {
          state = AuthEncryptionRequired(user);
        } else {
          state = AuthAuthenticated(user);
        }
    }
  }

  Future<void> forgotPassword(String email) async {
    state = const AuthLoading();
    final result = await _repository.forgotPassword(email: email);

    switch (result) {
      case Left(value: final failure):
        state = AuthUnauthenticated(error: failure.message);
      case Right():
        state = const AuthUnauthenticated(); // Success, allow navigation
    }
  }

  Future<void> resetPassword(String verificationCode, String password) async {
    state = const AuthLoading();
    final result = await _repository.resetPassword(
      verificationCode: verificationCode,
      password: password,
    );

    switch (result) {
      case Left(value: final failure):
        state = AuthUnauthenticated(error: failure.message);
      case Right():
        state = const AuthUnauthenticated(); // Success, allow navigation
    }
  }

  Future<void> register(String email, String password) async {
    state = const AuthLoading();
    final subscriptionId = await _oneSignal.getOneSignalId();

    final result = await _repository.register(
      email: email,
      password: password,
      oneSignalId: subscriptionId,
    );

    switch (result) {
      case Left(value: final failure):
        state = AuthUnauthenticated(error: failure.message);
      case Right(value: final data):
        final (user, token) = data;
        await _storage.saveToken(token);
        await _storage.saveUser(user);
        _oneSignal.setExternalUserId(user.id.toString());
        if (user.isEncrypted) {
          state = AuthEncryptionRequired(user);
        } else {
          state = AuthAuthenticated(user);
        }
    }
  }

  Future<void> setEncryptionKey(String key) async {
    final currentState = state;
    if (currentState is AuthEncryptionRequired) {
      final user = currentState.user;
      state = AuthEncryptionRequired(user, isLoading: true);

      final result = await _repository.verifyEncryptionKey(key);

      switch (result) {
        case Left(value: final failure):
          state = AuthEncryptionRequired(user, error: failure.message);
        case Right():
          await _storage.saveEncryptionKey(key);
          state = AuthAuthenticated(user);
      }
    }
  }

  void forceEncryptionRequired() {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      state = AuthEncryptionRequired(currentState.user);
    } else if (currentState is AuthEncryptionRequired) {
      // Already in state
    } else {
      checkAuthStatus();
    }
  }

  Future<void> loginWithGoogle() async {
    state = const AuthLoading();

    final signInResult = await _googleSignIn.signIn();

    switch (signInResult) {
      case Left(value: final failure):
        state = AuthUnauthenticated(error: failure.message);
      case Right(value: final account):
        final subscriptionId = await _oneSignal.getOneSignalId();

        final result = await _repository.googleLogin(
          email: account.email,
          googleId: account.id,
          oneSignalId: subscriptionId,
        );

        switch (result) {
          case Left(value: final failure):
            state = AuthUnauthenticated(error: failure.message);
          case Right(value: final data):
            final (user, token) = data;
            await _storage.saveToken(token);
            await _storage.saveUser(user);
            _oneSignal.setExternalUserId(user.id.toString());
            if (user.isEncrypted) {
              state = AuthEncryptionRequired(user);
            } else {
              state = AuthAuthenticated(user);
            }
        }
    }
  }

  Future<void> logout() async {
    _oneSignal.removeExternalUserId();
    await _storage.clearAll();
    state = const AuthUnauthenticated();
  }
}
