import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/assets/domain/asset.dart';

class CurrencyHistoryTimeline extends StatelessWidget {
  final List<Asset> assets;

  const CurrencyHistoryTimeline({
    super.key,
    required this.assets,
  });

  @override
  Widget build(BuildContext context) {
    // Sort transactions by date descending
    final sortedAssets = List<Asset>.from(assets);
    sortedAssets.sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: List.generate(sortedAssets.length, (index) {
        final asset = sortedAssets[index];
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TimelineNode(
                isFirst: index == 0,
                isLast: index == sortedAssets.length - 1,
                isBuy: asset.type == 'buy',
              ),
              const Gap(16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _TimelineItemCard(asset: asset),
                ),
              ),
            ],
          ),
        );
      }),
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
            height: 12,
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

class _TimelineItemCard extends StatelessWidget {
  final Asset asset;

  const _TimelineItemCard({required this.asset});

  @override
  Widget build(BuildContext context) {
    final isBuy = asset.type == 'buy';
    final amountColor = isBuy ? const Color(0xFF4ADE80) : const Color(0xFFF87171);
    final formatter = NumberFormat('#,##0.00', 'tr_TR');
    final formattedAmount = _formatAmount(asset.amount);
    final dateStr = DateFormat('d MMMM yyyy', 'tr_TR').format(asset.date);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isBuy ? 'Alış Yapıldı' : 'Satış Yapıldı',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(4),
                Text(
                  dateStr,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
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
                '₺${formatter.format(asset.price)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
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
