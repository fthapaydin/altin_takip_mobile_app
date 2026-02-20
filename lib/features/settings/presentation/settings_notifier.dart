import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/core/storage/storage_service.dart';
import 'package:altin_takip/features/auth/domain/auth_repository.dart';
import 'package:altin_takip/features/auth/domain/user.dart';
import 'package:altin_takip/features/settings/presentation/settings_state.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<SettingsState> {
  late final AuthRepository _authRepository;
  late final StorageService _storageService;

  @override
  SettingsState build() {
    _authRepository = sl<AuthRepository>();
    _storageService = sl<StorageService>();
    return const SettingsInitial();
  }

  Future<void> toggleEncryption({
    required bool enable,
    required String password,
  }) async {
    state = const SettingsLoading('encryption');

    final result = await _authRepository.toggleEncryption(
      status: enable,
      password: password,
    );

    result.fold((failure) => state = SettingsError(failure.message), (_) async {
      // Update key storage
      if (enable) {
        await _storageService.saveEncryptionKey(password);
      } else {
        await _storageService.clearEncryptionKey();
      }

      // Update local user data
      final currentUser = await _storageService.getUser();
      if (currentUser != null) {
        // Create new user with updated status
        // We use the base User class here, StorageService handles DTO conversion
        final updatedUser = User(
          id: currentUser.id,
          email: currentUser.email,
          isEncrypted: enable,
          oneSignalId: currentUser.oneSignalId,
        );
        await _storageService.saveUser(updatedUser);
      }

      state = SettingsSuccess(
        enable ? 'Şifreleme başarıyla etkinleştirildi' : 'Şifreleme kapatıldı',
      );
    });
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const SettingsLoading('password');

    final result = await _authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    result.fold(
      (failure) => state = SettingsError(failure.message),
      (_) => state = const SettingsSuccess('Şifre başarıyla değiştirildi'),
    );
  }

  Future<void> deleteAccount({required String password}) async {
    state = const SettingsLoading('delete');

    final result = await _authRepository.deleteAccount(password: password);

    result.fold((failure) => state = SettingsError(failure.message), (_) async {
      await _storageService.clearAll();
      state = const SettingsSuccess('Hesap silindi');
    });
  }

  Future<void> logout() async {
    state = const SettingsLoading('logout');
    await _storageService.clearAll();
    state = const SettingsSuccess('Çıkış yapıldı');
  }

  void reset() {
    state = const SettingsInitial();
  }
}
