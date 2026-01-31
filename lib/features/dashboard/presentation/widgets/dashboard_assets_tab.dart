import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/utils/date_formatter.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';
import 'package:altin_takip/features/settings/presentation/preference_notifier.dart';
import 'package:altin_takip/core/widgets/currency_icon.dart';

class DashboardAssetsTab extends ConsumerStatefulWidget {
  final AssetState state;
  final String type; // 'Altın' or 'Forex'
  final Function(Currency, bool) onNavigateToHistory;
  final Function(List<String>) onReorder;
  final List<String> currentOrder;

  const DashboardAssetsTab({
    super.key,
    required this.state,
    required this.type,
    required this.onNavigateToHistory,
    required this.onReorder,
    required this.currentOrder,
  });

  @override
  ConsumerState<DashboardAssetsTab> createState() => _DashboardAssetsTabState();
}

class _DashboardAssetsTabState extends ConsumerState<DashboardAssetsTab> {
  @override
  Widget build(BuildContext context) {
    if (widget.state is AssetLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppTheme.gold),
            const Gap(16),
            Text(
              'Kurlar yükleniyor...',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ],
        ),
      );
    }

    if (widget.state is AssetLoaded) {
      final isGoldTab = widget.type == 'Altın';
      final loadedState = widget.state as AssetLoaded;

      final filteredCurrencies = loadedState.currencies.where((c) {
        if (isGoldTab) return c.isGold;
        return !c.isGold;
      }).toList();

      final sortedCurrencies = _getSortedCurrencies(
        filteredCurrencies,
        widget.currentOrder,
      );

      return ReorderableListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
        itemCount: sortedCurrencies.length,
        proxyDecorator: (child, index, animation) {
          return Material(
            color: Colors.transparent,
            elevation: 4,
            shadowColor: AppTheme.gold.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            child: child,
          );
        },
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) newIndex--;
          final item = sortedCurrencies.removeAt(oldIndex);
          sortedCurrencies.insert(newIndex, item);

          final newOrder = sortedCurrencies.map((c) => c.code).toList();
          widget.onReorder(newOrder);
        },
        itemBuilder: (context, index) {
          final currency = sortedCurrencies[index];
          return Container(
            key: ValueKey(currency.code),
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildPremiumCurrencyCard(
              context,
              currency,
              isGold: isGoldTab,
              index: index,
            ),
          );
        },
      );
    }
    return const SizedBox();
  }

  List<Currency> _getSortedCurrencies(
    List<Currency> currencies,
    List<String> order,
  ) {
    if (order.isEmpty) return currencies;

    final sorted = List<Currency>.from(currencies);
    sorted.sort((a, b) {
      final indexA = order.indexOf(a.code);
      final indexB = order.indexOf(b.code);

      if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);
      if (indexA != -1) return -1;
      if (indexB != -1) return 1;
      return 0;
    });

    return sorted;
  }

  Widget _buildPremiumCurrencyCard(
    BuildContext context,
    Currency currency, {
    required bool isGold,
    required int index,
  }) {
    final useDynamicDate = ref.watch(preferenceProvider).useDynamicDate;
    final priceChange = currency.selling - currency.buying;
    final isPositive = priceChange >= 0;

    return GestureDetector(
      onTap: () => widget.onNavigateToHistory(currency, isGold),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.gold.withOpacity(0.2),
                      AppTheme.gold.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24), // Perfect circle
                  border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
                ),
                child: CurrencyIcon(
                  iconUrl: currency.iconUrl,
                  isGold: isGold,
                  size: 48,
                  color: AppTheme.gold,
                ),
              ),
              const Gap(16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGold ? currency.name : currency.code,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Text(
                      DateFormatter.format(
                        currency.lastUpdatedAt,
                        useDynamic: useDynamicDate,
                      ),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Prices
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '₺${NumberFormat('#,##0.00', 'tr_TR').format(currency.selling)}',
                    style: const TextStyle(
                      fontFeatures: [FontFeature.tabularFigures()],
                      color: AppTheme.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Gap(4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Alış: ₺${NumberFormat('#,##0.00', 'tr_TR').format(currency.buying)}',
                        style: TextStyle(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (isPositive ? Colors.green : Colors.red)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${isPositive ? "+" : ""}%${NumberFormat('#,##0.00', 'tr_TR').format((priceChange / currency.buying) * 100)}',
                          style: TextStyle(
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontSize: 10,
                            color: isPositive
                                ? Color(0xFF4ADE80)
                                : Color(0xFFF87171),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
