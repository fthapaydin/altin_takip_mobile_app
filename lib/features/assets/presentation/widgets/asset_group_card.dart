import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/utils/date_formatter.dart';
import 'package:altin_takip/core/widgets/currency_icon.dart';
import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:altin_takip/features/currencies/presentation/history/currency_history_screen.dart';
import 'package:altin_takip/features/settings/presentation/preference_notifier.dart';
import 'package:altin_takip/features/assets/presentation/widgets/asset_options_sheet.dart';
import 'package:altin_takip/core/widgets/dashed_line_painter.dart';

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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isExpanded
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpanded
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Drag Handle
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        Iconsax.menu_1,
                        color: Colors.white.withValues(alpha: 0.2),
                        size: 20,
                      ),
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    child: CurrencyIcon(
                      iconUrl: currency?.iconUrl,
                      isGold: isGold,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGold
                              ? (currency?.name ?? currencyCode)
                              : currencyCode,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Gap(4),
                        Row(
                          children: [
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
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${assets.length} işlem',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Gap(4),
                                    Icon(
                                      Iconsax.arrow_right_3,
                                      size: 10,
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_formatAmount(netAmount)} adet',
                        style: TextStyle(
                          color: isGold ? AppTheme.gold : Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '₺${NumberFormat('#,##0.00', 'tr_TR').format(currentValue)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.arrow_down_1,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 16,
                      ),
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
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
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
            color: Colors.white.withValues(alpha: 0.05),
            height: 1,
            thickness: 1,
          ),
          const Gap(16),
          if (buys.isNotEmpty) ...[
            _buildTransactionSectionHeader(
              'Geçmiş İşlemler',
              Colors.white.withValues(alpha: 0.2),
            ),
            const Gap(12),
            ...buys.asMap().entries.map((entry) {
              final index = entry.key;
              final asset = entry.value;
              return _buildTimelineWrapper(
                context,
                ref,
                asset,
                isFirst: index == 0,
                isLast: index == buys.length - 1,
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
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    WidgetRef ref,
    Asset asset, {
    bool isLast = false,
  }) {
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
    final currentValue = asset.amount * currentPrice;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to top
        children: [
          // Timeline Spacer (left side of screen)
          const SizedBox(width: 80),

          Expanded(
            child: InkWell(
              onTap: () => AssetOptionsSheet.show(context, asset),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 24,
                  bottom: 24, // Consistent spacing
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Transaction Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            (isBuy
                                    ? const Color(0xFF4ADE80)
                                    : const Color(0xFFF87171))
                                .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isBuy ? Iconsax.arrow_bottom : Iconsax.arrow_up,
                        color: isBuy
                            ? const Color(0xFF4ADE80)
                            : const Color(0xFFF87171),
                        size: 20,
                      ),
                    ),
                    const Gap(12),

                    // 2. Type and Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBuy ? 'Alış' : 'Satış',
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            dateStr,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),

                    // 3. Financial Details (Right aligned)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Amount
                        Text(
                          '${_formatAmount(asset.amount)} adet',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        const Gap(4),

                        // Unit Price
                        Text(
                          'Birim: ₺${NumberFormat('#,##0.00', 'tr_TR').format(asset.price)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),

                        // Total Cost (Alış Tutarı)
                        const Gap(2),
                        Text(
                          'Maliyet: ₺${NumberFormat('#,##0.00', 'tr_TR').format(totalCost)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),

                        if (isBuy && asset.currency != null) ...[
                          const Gap(2),
                          // Current Value (Güncel Değer)
                          Text(
                            'Değer: ₺${NumberFormat('#,##0.00', 'tr_TR').format(currentValue)}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],

                        if (profit != null) ...[
                          const Gap(6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (isProfitPositive
                                          ? const Color(0xFF4ADE80)
                                          : const Color(0xFFF87171))
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${isProfitPositive ? '+' : ''}₺${NumberFormat('#,##0.00', 'tr_TR').format(profit)} ${profitPercent != null ? '(%${profitPercent.toStringAsFixed(1)})' : ''}',
                              style: TextStyle(
                                fontFeatures: [FontFeature.tabularFigures()],
                                color: isProfitPositive
                                    ? const Color(0xFF4ADE80)
                                    : const Color(0xFFF87171),
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineWrapper(
    BuildContext context,
    WidgetRef ref,
    Asset asset, {
    bool isLast = false,
    bool isFirst = false,
  }) {
    final isBuy = asset.type == 'buy';
    final color = isBuy
        ? const Color(0xFF4ADE80)
        : const Color(0xFFF87171); // Green : Red

    return Stack(
      children: [
        // Lines
        Positioned(
          left: 0,
          width: 80,
          top: 0,
          bottom: 0,
          child: Center(
            child: Container(
              width: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Top line (0 to 6) - Stops before the 32px icon starts
                  if (!isFirst)
                    Positioned(
                      top: 0,
                      height: 6,
                      child: CustomPaint(
                        size: const Size(2, 6),
                        painter: DashedLinePainter(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  // Bottom line (38 to end) - Starts after the 32px icon ends
                  // Icon center is 22. Icon radius is 16. End is 22+16=38.
                  if (!isLast)
                    Positioned(
                      top: 38,
                      bottom: 0,
                      child: CustomPaint(
                        size: Size(2, double.infinity),
                        painter: DashedLinePainter(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        _buildTransactionItem(context, ref, asset, isLast: isLast),

        // Icon
        Positioned(
          left: 0,
          width: 80,
          top: 0,
          child: Center(
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.transparent, // Removed background
                shape: BoxShape.circle,
              ),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  isBuy ? Iconsax.arrow_down_1 : Iconsax.arrow_up_1,
                  color: color,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatAmount(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return NumberFormat('#,##0.##', 'tr_TR').format(value);
  }
}
