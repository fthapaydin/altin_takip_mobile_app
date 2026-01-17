import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/core/storage/storage_service.dart';

class PreferenceState {
  final bool useDynamicDate;

  const PreferenceState({required this.useDynamicDate});

  PreferenceState copyWith({bool? useDynamicDate}) {
    return PreferenceState(
      useDynamicDate: useDynamicDate ?? this.useDynamicDate,
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
}
