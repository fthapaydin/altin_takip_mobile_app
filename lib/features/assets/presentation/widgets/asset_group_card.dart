import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/utils/date_formatter.dart';
import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:altin_takip/features/currencies/presentation/history/currency_history_screen.dart';
import 'package:altin_takip/features/settings/presentation/preference_notifier.dart';
import 'package:altin_takip/features/assets/presentation/widgets/asset_options_sheet.dart';

class AssetGroupCard extends ConsumerWidget {
  final String currencyCode;
  final List<Asset> assets;
  final bool isExpanded;
  final VoidCallback onToggle;
  final int index;

  const AssetGroupCard({
    super.key,
    required this.currencyCode,
    required this.assets,
    required this.isExpanded,
    required this.onToggle,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine currency info from the first asset
    final currency = assets.first.currency;
    final isGold = currency?.isGold ?? false;

    // 1. Net Quantity
    final double netAmount = assets.fold(0, (sum, item) {
      return sum + (item.type == 'buy' ? item.amount : -item.amount);
    });

    // 2. Average Cost Calculation (Weighted Average of Buys)
    final buys = assets.where((a) => a.type == 'buy');
    double totalBuyAmount = 0;
    double totalBuyCost = 0;

    for (final buy in buys) {
      totalBuyAmount += buy.amount;
      totalBuyCost += (buy.amount * buy.price);
    }

    final double avgCost = totalBuyAmount > 0
        ? totalBuyCost / totalBuyAmount
        : 0;

    // 3. Current Value (Market Value of Holdings)
    // For gold: Amount * Buying Price (BoZDURMA fiyatı)
    // For regular currency: Amount * Buying Price
    // Note: Usually 'buying' is what bank buys from you (your sell price)
    final double currentPrice = currency?.buying ?? 0;
    final double currentValue = netAmount * currentPrice;

    // 4. Total Cost of Current Holdings
    final double totalCost = netAmount * avgCost;

    // 5. Profit / Loss
    final double profit = currentValue - totalCost;
    final double profitPercent = totalCost > 0 ? (profit / totalCost) * 100 : 0;


    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isGold
              ? [
                  const Color(0xFF15181F),
                  const Color(0xFF0F1014),
                ]
              : [
                  const Color(0xFF12151D),
                  const Color(0xFF0C0E13),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGold 
              ? AppTheme.gold.withValues(alpha: 0.08) 
              : const Color(0xFF60A5FA).withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: Row(
                children: [
                  // Drag Handle
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Iconsax.menu_1,
                        color: Colors.white.withValues(alpha: 0.2),
                        size: 18,
                      ),
                    ),
                  ),
                  
                  // ── Sleek Vertical Accent Indicator ──
                  Container(
                    width: 3,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isGold ? AppTheme.gold : const Color(0xFF60A5FA),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Gap(12),
                  
                  // Info Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGold
                              ? (currency?.name ?? currencyCode)
                              : currencyCode,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(4),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CurrencyHistoryScreen(
                                  currencyCode: currencyCode,
                                  currencyId: currency?.id.toString() ?? '',
                                  currencyName:
                                      currency?.name ?? currencyCode,
                                  isGold: isGold,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            '${assets.length} işlem ›',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  
                  // Totals Column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_formatAmount(netAmount)} adet',
                        style: TextStyle(
                          color: isGold ? AppTheme.gold : Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '₺${NumberFormat('#,##0.00', 'tr_TR').format(currentValue)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  
                  // Expand chevron
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Iconsax.arrow_down_1,
                      color: Colors.white.withValues(alpha: 0.25),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Helper method for Summary Stats
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.background.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Average Cost
                    _buildSummaryItem(
                      'Ortalama',
                      '₺${NumberFormat('#,##0.00', 'tr_TR').format(avgCost)}',
                      Colors.white,
                    ),
                    // Total Cost (Maliyet)
                    _buildSummaryItem(
                      'Maliyet',
                      '₺${NumberFormat('#,##0.00', 'tr_TR').format(totalCost)}',
                      Colors.white,
                    ),
                    // Profit / Loss
                    _buildSummaryItem(
                      'Kar/Zarar',
                      '${profit >= 0 ? '+' : ''}₺${NumberFormat('#,##0.##', 'tr_TR').format(profit)}',
                      profit >= 0
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFFF87171),
                      subtitle: '%${profitPercent.toStringAsFixed(1)}',
                    ),
                  ],
                ),
              ),
            ),

          // Expandable transactions
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildGroupedTransactions(context, ref),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    Color valueColor, {
    String? subtitle,
  }) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
        const Gap(4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        if (subtitle != null) ...[
          const Gap(2),
          Text(
            subtitle,
            style: TextStyle(
              color: valueColor.withValues(alpha: 0.8),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGroupedTransactions(BuildContext context, WidgetRef ref) {
    // Sort transactions by date descending (newest first)
    final buys = assets.where((a) => a.type == 'buy').toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            color: Colors.white.withValues(alpha: 0.04),
            height: 1,
            thickness: 1,
          ),
          const Gap(16),
          if (buys.isNotEmpty) ...[
            _buildTransactionSectionHeader(
              'Geçmiş İşlemler',
              Colors.white.withValues(alpha: 0.2),
            ),
            const Gap(8),
            ...buys.asMap().entries.map((entry) {
              final index = entry.key;
              final asset = entry.value;
              return Column(
                children: [
                  if (index > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Divider(
                        color: Colors.white.withValues(alpha: 0.04),
                        height: 1,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: _buildTransactionItem(context, ref, asset),
                  ),
                ],
              );
            }),
          ],
          if (buys.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Görüntülenecek aktif varlık bulunamadı.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    WidgetRef ref,
    Asset asset,
  ) {
    final isBuy = asset.type == 'buy';
    final useDynamicDate = ref.watch(preferenceProvider).useDynamicDate;

    // Format date string
    String dateStr;
    if (useDynamicDate) {
      dateStr = DateFormatter.format(asset.date, useDynamic: true);
    } else {
      dateStr = DateFormat('d MMM yyyy, HH:mm', 'tr_TR').format(asset.date);
    }

    // Calculate financials
    double? profit;
    double? profitPercent;
    double currentPrice = 0;

    if (isBuy && asset.currency != null) {
      currentPrice = asset.currency!.buying;
      final costPrice = asset.price;
      profit = (currentPrice - costPrice) * asset.amount;

      final totalCost = costPrice * asset.amount;
      if (totalCost > 0) {
        profitPercent = (profit / totalCost) * 100;
      }
    }

    final isProfitPositive = profit != null && profit >= 0;
    final totalCost = asset.amount * asset.price;
    final formatter = NumberFormat('#,##0.00', 'tr_TR');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => AssetOptionsSheet.show(context, asset),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              // Tiny vertical status indicator (green for buy, red for sell)
              Container(
                width: 3,
                height: 32,
                decoration: BoxDecoration(
                  color: isBuy ? const Color(0xFF4ADE80) : const Color(0xFFF87171),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const Gap(12),
              
              // Content Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Alış/Satış and amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isBuy ? 'Alış' : 'Satış',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${_formatAmount(asset.amount)} adet',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),
                    // Row 2: Date and Total Cost (Maliyet)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateStr,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'Maliyet: ₺${formatter.format(totalCost)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),
                    // Row 3: Unit Price and Profit/Loss tag
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Birim: ₺${formatter.format(asset.price)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        if (profit != null)
                          _ProfitTagCompact(
                            profit: profit,
                            profitPercent: profitPercent,
                            isProfitPositive: isProfitPositive,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(10),
              Icon(
                Iconsax.arrow_right_3,
                color: Colors.white.withValues(alpha: 0.25),
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAmount(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return NumberFormat('#,##0.##', 'tr_TR').format(value);
  }
}

class _ProfitTagCompact extends StatelessWidget {
  final double profit;
  final double? profitPercent;
  final bool isProfitPositive;

  const _ProfitTagCompact({
    required this.profit,
    this.profitPercent,
    required this.isProfitPositive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isProfitPositive ? const Color(0xFF4ADE80) : const Color(0xFFF87171);
    final formatter = NumberFormat('#,##0.00', 'tr_TR');
    final sign = isProfitPositive ? '+' : '';
    final percentStr = profitPercent != null ? ' ($sign${profitPercent!.toStringAsFixed(1)}%)' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.12), width: 1),
      ),
      child: Text(
        '$sign₺${formatter.format(profit)}$percentStr',
        style: TextStyle(
          fontFeatures: const [FontFeature.tabularFigures()],
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
