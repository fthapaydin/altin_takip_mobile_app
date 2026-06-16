import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';
import 'package:altin_takip/core/utils/date_formatter.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final List<Asset> assets;
  final Function(Currency, bool) onNavigateToHistory;
  final VoidCallback onShowAddAsset;
  final bool useDynamicDate;

  const RecentTransactionsWidget({
    super.key,
    required this.assets,
    required this.onNavigateToHistory,
    required this.onShowAddAsset,
    required this.useDynamicDate,
  });

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return _EmptyState(onShowAddAsset: onShowAddAsset);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: List.generate(assets.length, (index) {
          final asset = assets[index];
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TimelineNode(
                  isFirst: index == 0,
                  isLast: index == assets.length - 1,
                  isBuy: asset.type == 'buy',
                ),
                const Gap(16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _TransactionCard(
                      asset: asset,
                      useDynamicDate: useDynamicDate,
                      onTap: () {
                        if (asset.currency != null) {
                          onNavigateToHistory(asset.currency!, asset.currency!.isGold);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool isBuy;

  const _TimelineNode({
    required this.isFirst,
    required this.isLast,
    required this.isBuy,
  });

  @override
  Widget build(BuildContext context) {
    final color = isBuy ? const Color(0xFF4ADE80) : const Color(0xFFF87171);

    return SizedBox(
      width: 16,
      child: Column(
        children: [
          Container(
            width: 1.5,
            height: 16,
            color: isFirst ? Colors.transparent : Colors.white.withOpacity(0.08),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
          ),
          Expanded(
            child: Container(
              width: 1.5,
              color: isLast ? Colors.transparent : Colors.white.withOpacity(0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Asset asset;
  final bool useDynamicDate;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.asset,
    required this.useDynamicDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isBuy = asset.type == 'buy';
    final dateStr = useDynamicDate
        ? DateFormatter.format(asset.date, useDynamic: true)
        : DateFormat('d MMM yyyy, HH:mm', 'tr_TR').format(asset.date);

    double? profit;
    if (isBuy && asset.currency != null) {
      profit = (asset.currency!.buying - asset.price) * asset.amount;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.currency?.name ?? 'Bilinmeyen Varlık',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '${isBuy ? 'Alış' : 'Satış'} • $dateStr',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                _buildValueSection(profit),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValueSection(double? profit) {
    final isBuy = asset.type == 'buy';
    final amountColor = isBuy ? const Color(0xFF4ADE80) : const Color(0xFFF87171);
    final formattedAmount = _formatAmount(asset.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${isBuy ? '+' : '-'}$formattedAmount adet',
          style: TextStyle(
            color: amountColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const Gap(4),
        Text(
          '₺${NumberFormat('#,##0.00', 'tr_TR').format(asset.price)}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
        if (profit != null && profit != 0) ...[
          const Gap(4),
          _ProfitTag(profit: profit),
        ],
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

class _ProfitTag extends StatelessWidget {
  final double profit;

  const _ProfitTag({required this.profit});

  @override
  Widget build(BuildContext context) {
    final isPositive = profit >= 0;
    final color = isPositive ? const Color(0xFF4ADE80) : const Color(0xFFF87171);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${isPositive ? '+' : ''}₺${NumberFormat('#,##0.00', 'tr_TR').format(profit)}',
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w500,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onShowAddAsset;

  const _EmptyState({required this.onShowAddAsset});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          const Text(
            'Henüz bir işlem yapmadınız.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w400),
          ),
          const Gap(16),
          ElevatedButton(
            onPressed: onShowAddAsset,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gold,
              foregroundColor: Colors.black,
              minimumSize: const Size(120, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('İşlem Ekle', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }
}
