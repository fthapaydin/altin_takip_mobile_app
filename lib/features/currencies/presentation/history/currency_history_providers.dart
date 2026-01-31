import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/features/currencies/domain/currency_repository.dart';
import 'package:altin_takip/features/currencies/domain/currency_history_data.dart';

// Provider for the selected range map (CurrencyID -> Range)
// We use a Map to simulate family behavior without relying on FamilyNotifier classes
// that seem to be missing or incompatible.
class RangeNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() {
    return {};
  }

  void setRange(String currencyId, String range) {
    state = {...state, currencyId: range};
  }

  String getRange(String currencyId) {
    return state[currencyId] ?? '1w';
  }
}

final currencyHistoryRangeProvider =
    NotifierProvider<RangeNotifier, Map<String, String>>(() => RangeNotifier());

// Provider for the history data based on currencyId and range
final currencyHistoryProvider = FutureProvider.autoDispose
    .family<CurrencyHistoryData, String>((ref, currencyId) async {
      final repository = sl<CurrencyRepository>();
      // Watch the range map
      final rangeMap = ref.watch(currencyHistoryRangeProvider);
      final range = rangeMap[currencyId] ?? '1w';

      final result = await repository.getHistory(currencyId, range);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (data) => data,
      );
    });
