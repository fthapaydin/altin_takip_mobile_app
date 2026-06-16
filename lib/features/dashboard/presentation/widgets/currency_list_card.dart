import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';
import 'package:altin_takip/core/utils/date_formatter.dart';

class CurrencyListCard extends StatelessWidget {
  final Currency currency;
  final bool isGold;
  final bool useDynamicDate;
  final VoidCallback onTap;

  const CurrencyListCard({
    super.key,
    required this.currency,
    required this.isGold,
    required this.useDynamicDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final priceChange = currency.selling - currency.buying;
    final isPositive = priceChange >= 0;
    final formatter = NumberFormat('#,##0.00', 'tr_TR');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isGold
              ? [const Color(0xFF15181F), const Color(0xFF0F1014)]
              : [const Color(0xFF12151D), const Color(0xFF0C0E13)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGold
              ? AppTheme.gold.withOpacity(0.08)
              : const Color(0xFF60A5FA).withOpacity(0.04),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(
              children: [
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

                // ── Main Content Area ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Row 1: Name and Selling Price + Yield
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isGold ? currency.name : currency.code,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: Colors.white,
                                letterSpacing: 0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Gap(12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₺${formatter.format(currency.selling)}',
                                style: const TextStyle(
                                  fontFeatures: [FontFeature.tabularFigures()],
                                  color: AppTheme.gold,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const Gap(8),
                              _YieldTag(
                                priceChange: priceChange,
                                buying: currency.buying,
                                isPositive: isPositive,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Gap(6),
                      // Row 2: Code + Date and Buying Price
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              DateFormatter.format(
                                currency.lastUpdatedAt,
                                useDynamic: useDynamicDate,
                              ),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.35),
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Gap(12),
                          Text(
                            'Alış: ₺${formatter.format(currency.buying)}',
                            style: TextStyle(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(10),
                // Tappable indicator chevron
                Icon(
                  Iconsax.arrow_right_3,
                  size: 14,
                  color: Colors.white.withOpacity(0.25),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _YieldTag extends StatelessWidget {
  final double priceChange;
  final double buying;
  final bool isPositive;

  const _YieldTag({
    required this.priceChange,
    required this.buying,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive
        ? const Color(0xFF4ADE80)
        : const Color(0xFFF87171);
    final percentage = (priceChange / buying) * 100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.12), width: 1),
      ),
      child: Text(
        '${isPositive ? "+" : ""}%${NumberFormat('#,##0.00', 'tr_TR').format(percentage)}',
        style: TextStyle(
          fontFeatures: const [FontFeature.tabularFigures()],
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
