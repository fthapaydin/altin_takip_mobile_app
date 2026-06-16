import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/assets/domain/asset.dart';

class CurrencyInvestmentSummary extends StatelessWidget {
  final List<Asset> assets;
  final double currentPrice;

  const CurrencyInvestmentSummary({
    super.key,
    required this.assets,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    double totalAmount = 0;
    double totalCost = 0;

    for (final asset in assets) {
      if (asset.type == 'buy') {
        totalAmount += asset.amount;
        totalCost += (asset.price * asset.amount);
      } else if (asset.type == 'sell') {
        totalAmount -= asset.amount;
        totalCost -= (asset.price * asset.amount);
      }
    }

    if (totalAmount <= 0) return const SizedBox.shrink();

    final currentValue = totalAmount * currentPrice;
    final profit = currentValue - totalCost;
    final profitPercentage = totalCost > 0 ? (profit / totalCost) * 100 : 0.0;
    final isProfitPositive = profit >= 0;
    final profitColor = isProfitPositive ? const Color(0xFF4ADE80) : const Color(0xFFF87171);
    final formatter = NumberFormat('#,##0.00', 'tr_TR');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOPLAM VARLIK DEĞERİ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
          const Gap(6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₺${formatter.format(currentValue)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.5,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const Gap(8),
              Text(
                '${NumberFormat('#,##0.###', 'tr_TR').format(totalAmount)} adet',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const Gap(16),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: _SummaryStatTile(
                  label: 'Toplam Maliyet',
                  value: '₺${formatter.format(totalCost)}',
                  valueColor: Colors.white.withOpacity(0.9),
                ),
              ),
              Container(width: 1, height: 32, color: Colors.white.withOpacity(0.06)),
              Expanded(
                child: _SummaryStatTile(
                  label: 'Kâr / Zarar',
                  value: '${isProfitPositive ? '+' : ''}₺${formatter.format(profit)}',
                  valueColor: profitColor,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: profitColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${isProfitPositive ? '+' : ''}%${profitPercentage.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        color: profitColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Widget? trailing;

  const _SummaryStatTile({
    required this.label,
    required this.value,
    required this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Gap(4),
          Row(
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) ...[
                const Gap(6),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}
