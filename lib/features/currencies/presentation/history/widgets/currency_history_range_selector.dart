import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/currencies/presentation/history/currency_history_providers.dart';

/// Range selector tabs for switching between historical data ranges.
class CurrencyHistoryRangeSelector extends ConsumerWidget {
  final String currencyId;
  final bool isGold;

  const CurrencyHistoryRangeSelector({
    super.key,
    required this.currencyId,
    required this.isGold,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRange = ref.watch(currencyHistoryRangeProvider)[currencyId] ?? '1w';

    final ranges = ['1d', '1w', '1m', '3m', '1y', 'all'];
    final labels = {
      '1d': '1G',
      '1w': '1H',
      '1m': '1A',
      '3m': '3A',
      '1y': '1Y',
      'all': 'Tümü',
    };

    final selectorColor = isGold ? AppTheme.gold : Colors.white;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ranges.map((range) {
          final isSelected = range == selectedRange;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(currencyHistoryRangeProvider.notifier).setRange(currencyId, range);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? selectorColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    labels[range]!,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white54,
                      fontWeight: isSelected ? FontWeight.w400 : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
