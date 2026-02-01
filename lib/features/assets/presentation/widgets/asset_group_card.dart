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
    final totalAmount = assets.fold<double>(
      0,
      (sum, a) => sum + (a.type == 'buy' ? a.amount : -a.amount),
    );
    final totalValue = assets.fold<double>(
      0,
      (sum, a) =>
          sum + (a.type == 'buy' ? a.amount * a.price : -a.amount * a.price),
    );

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
                            fontWeight: FontWeight.bold,
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
                        '${_formatAmount(totalAmount)} adet',
                        style: TextStyle(
                          color: isGold ? AppTheme.gold : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '₺${NumberFormat('#,##0.00', 'tr_TR').format(totalValue.abs())}',
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

  Widget _buildGroupedTransactions(BuildContext context, WidgetRef ref) {
    final buys = assets.where((a) => a.type == 'buy').toList();

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
              'Varlıklar',
              Colors.white.withValues(alpha: 0.2),
            ),
            const Gap(12),
            ...buys.map(
              (asset) => _buildTransactionItem(
                context,
                ref,
                asset,
                isLast: asset == buys.last,
              ),
            ),
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
    final formattedDate = DateFormatter.format(
      asset.date,
      useDynamic: useDynamicDate,
    );

    double? profit;
    if (isBuy && asset.currency != null) {
      final currentPrice = asset.currency!.buying;
      final costPrice = asset.price;
      profit = (currentPrice - costPrice) * asset.amount;
    }

    final isProfitPositive = profit != null && profit >= 0;

    return InkWell(
      onTap: () => AssetOptionsSheet.show(context, asset),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isBuy ? Colors.green : Colors.red).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(12), // Squircle
                border: Border.all(
                  color: (isBuy ? Colors.green : Colors.red).withValues(
                    alpha: 0.2,
                  ),
                  width: 1,
                ),
              ),
              child: Icon(
                isBuy ? Iconsax.arrow_down_1 : Iconsax.arrow_up_1,
                color: isBuy ? Colors.green : Colors.red,
                size: 18,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBuy ? 'Alış' : 'Satış',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const Gap(2),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_formatAmount(asset.amount)} adet',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                const Gap(4),
                Text(
                  '₺${NumberFormat('#,##0.00', 'tr_TR').format(asset.price)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
                if (profit != null) ...[
                  const Gap(2),
                  Text(
                    '${isProfitPositive ? '+' : ''}₺${NumberFormat('#,##0.00', 'tr_TR').format(profit)}',
                    style: TextStyle(
                      fontFeatures: [FontFeature.tabularFigures()],
                      color: isProfitPositive
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFFF87171),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
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
