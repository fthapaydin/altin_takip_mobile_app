import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/core/storage/storage_service.dart';

class PreferenceState {
  final bool useDynamicDate;
  final int resetToken;

  const PreferenceState({required this.useDynamicDate, this.resetToken = 0});

  PreferenceState copyWith({bool? useDynamicDate, int? resetToken}) {
    return PreferenceState(
      useDynamicDate: useDynamicDate ?? this.useDynamicDate,
      resetToken: resetToken ?? this.resetToken,
    );
  }
}

final preferenceProvider =
    NotifierProvider<PreferenceNotifier, PreferenceState>(
      PreferenceNotifier.new,
    );

class PreferenceNotifier extends Notifier<PreferenceState> {
  late final StorageService _storageService;

  @override
  PreferenceState build() {
    _storageService = sl<StorageService>();
    _loadPreferences();
    return const PreferenceState(useDynamicDate: true);
  }

  Future<void> _loadPreferences() async {
    final useDynamic = await _storageService.getUseDynamicDate();
    state = state.copyWith(useDynamicDate: useDynamic);
  }

  Future<void> toggleDynamicDate(bool value) async {
    await _storageService.saveUseDynamicDate(value);
    state = state.copyWith(useDynamicDate: value);
  }

  Future<void> resetOrdering() async {
    await _storageService.clearAssetOrdering();
    state = state.copyWith(resetToken: state.resetToken + 1);
  }
}
