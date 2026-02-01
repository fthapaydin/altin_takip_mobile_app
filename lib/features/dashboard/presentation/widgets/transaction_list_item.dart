import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';

import 'package:altin_takip/features/assets/domain/asset.dart';

class TransactionListItem extends StatelessWidget {
  final Asset asset;

  const TransactionListItem({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final isBuy = asset.type == 'buy';
    final currentPrice = asset.currency?.selling ?? asset.price;
    final diff = (currentPrice - asset.price) * asset.amount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), // Darker, premium background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isBuy ? Colors.green : Colors.red).withValues(
                      alpha: 0.1,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (isBuy ? Colors.green : Colors.red).withValues(
                        alpha: 0.2,
                      ),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    isBuy ? Iconsax.arrow_circle_down : Iconsax.arrow_circle_up,
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
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(4),
                      Text(
                        DateFormat(
                          'd MMMM yyyy, HH:mm',
                          'tr_TR',
                        ).format(asset.date),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
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
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Gap(4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (diff >= 0 ? Colors.green : Colors.red)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${diff >= 0 ? "+" : ""}₺${NumberFormat('#,##0.00', 'tr_TR').format(diff)}',
                        style: TextStyle(
                          fontFeatures: [FontFeature.tabularFigures()],
                          color: diff >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
