import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/widgets/app_bar_widget.dart';
import 'package:altin_takip/core/widgets/premium_error_view.dart';
import 'package:altin_takip/features/currencies/domain/currency_history.dart';
import 'package:altin_takip/features/currencies/domain/currency_history_data.dart';
import 'package:altin_takip/features/currencies/presentation/history/currency_history_providers.dart';
import 'package:altin_takip/features/currencies/presentation/history/widgets/currency_investment_summary.dart';
import 'package:altin_takip/features/currencies/presentation/history/widgets/currency_history_timeline.dart';
import 'package:altin_takip/features/currencies/presentation/history/widgets/currency_history_shimmer.dart';
import 'package:altin_takip/features/currencies/presentation/history/widgets/currency_history_chart.dart';
import 'package:altin_takip/features/currencies/presentation/history/widgets/currency_history_range_selector.dart';
import 'package:altin_takip/features/currencies/presentation/history/widgets/currency_history_empty_state.dart';

/// Screen presenting the detailed price history, chart, and transaction records of a selected currency.
class CurrencyHistoryScreen extends ConsumerStatefulWidget {
  final String currencyCode;
  final String currencyId;
  final String currencyName;
  final bool isGold;

  const CurrencyHistoryScreen({
    super.key,
    required this.currencyCode,
    required this.currencyId,
    required this.currencyName,
    required this.isGold,
  });

  @override
  ConsumerState<CurrencyHistoryScreen> createState() =>
      _CurrencyHistoryScreenState();
}

class _CurrencyHistoryScreenState extends ConsumerState<CurrencyHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBarWidget(
        title: widget.currencyName,
        isLargeTitle: false,
        showBack: true,
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Consumer(
              builder: (context, ref, child) {
                final historyAsync = ref.watch(currencyHistoryProvider(widget.currencyId));
                final isLoading = historyAsync.isRefreshing || (historyAsync.isLoading && historyAsync.hasValue);

                if (historyAsync.hasValue) {
                  return Stack(
                    children: [
                      _buildContent(historyAsync.value!),
                      if (isLoading)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                            color: (widget.isGold ? AppTheme.gold : Colors.white).withValues(alpha: 0.5),
                            minHeight: 2,
                          ),
                        ),
                    ],
                  );
                }

                return historyAsync.when(
                  data: _buildContent,
                  loading: () => const CurrencyHistoryShimmer(),
                  error: (error, stack) => PremiumErrorView(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(currencyHistoryProvider(widget.currencyId)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(CurrencyHistoryData data) {
    if (data.history.isEmpty) {
      return const Center(child: CurrencyHistoryEmptyState(currencyCode: ''));
    }

    final sortedHistory = List<CurrencyHistory>.from(data.history)
      ..sort((a, b) => a.date.compareTo(b.date));

    final lastItem = sortedHistory.last;
    final firstItem = sortedHistory.first;
    final change = lastItem.buying - firstItem.buying;
    final percentage = (change / firstItem.buying) * 100;
    final isPositive = change >= 0;

    final double topPadding = MediaQuery.of(context).padding.top +
        AppBarWidget.getExpandedHeight(isLargeTitle: false) +
        12.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildPriceItem('Alış', lastItem.buying),
                    const Gap(24),
                    _buildPriceItem('Satış', lastItem.selling),
                  ],
                ),
                const Gap(8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isPositive ? Colors.green : Colors.red).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive ? Iconsax.trend_up : Iconsax.trend_down,
                            size: 14,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                          const Gap(4),
                          Text(
                            '%${percentage.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              color: isPositive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'Son güncelleme: ${lastItem.date.hour == 0 && lastItem.date.minute == 0 ? DateFormat('dd.MM.yyyy').format(lastItem.date) : DateFormat('HH:mm').format(lastItem.date)}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const Gap(20),
        SizedBox(
          height: 250,
          child: CurrencyHistoryChart(history: sortedHistory, isGold: widget.isGold),
        ),
        const Gap(16),
        CurrencyHistoryRangeSelector(currencyId: widget.currencyId, isGold: widget.isGold),
        const Gap(24),
        if (data.userAssets.isNotEmpty) ...[
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Yatırım Özeti',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400),
            ),
          ),
          const Gap(16),
          CurrencyInvestmentSummary(assets: data.userAssets, currentPrice: lastItem.buying),
          const Gap(24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Geçmiş İşlemlerim',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400),
            ),
          ),
          const Gap(16),
          CurrencyHistoryTimeline(assets: data.userAssets),
        ] else
          CurrencyHistoryEmptyState(currencyCode: widget.currencyCode),
        const Gap(40),
      ],
    );
  }

  Widget _buildPriceItem(String label, double price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const Gap(4),
        Text(
          '₺${NumberFormat('#,##0.00', 'tr_TR').format(price)}',
          style: TextStyle(
            color: widget.isGold ? AppTheme.gold : Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
