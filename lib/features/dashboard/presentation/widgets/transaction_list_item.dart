import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';

import 'package:altin_takip/features/assets/domain/asset.dart';

class TransactionListItem extends StatelessWidget {
  final Asset asset;

  final VoidCallback onTap;

  const TransactionListItem({
    super.key,
    required this.asset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isBuy = asset.type == 'buy';
    final currentPrice = asset.currency?.selling ?? asset.price;
    final diff = (currentPrice - asset.price) * asset.amount;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              // Icon Box
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isBuy ? Colors.green : Colors.red).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(14), // Squircle
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
                  size: 20,
                ),
              ),
              const Gap(16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.currency?.name ?? 'Bilinmeyen Varlık',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Text(
                      DateFormat('d MMMM, HH:mm', 'tr_TR').format(asset.date),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Values
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${NumberFormat('#,##0.###', 'tr_TR').format(asset.amount)} adet',
                    style: const TextStyle(
                      fontFeatures: [FontFeature.tabularFigures()],
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    '${diff >= 0 ? "+" : ""}₺${NumberFormat('#,##0.00', 'tr_TR').format(diff)}',
                    style: TextStyle(
                      fontFeatures: [FontFeature.tabularFigures()],
                      color: diff >= 0
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFFF87171),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
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
