import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/public_prices/domain/public_price.dart';
import 'package:altin_takip/features/public_prices/presentation/public_price_detail_screen.dart';

class PublicPriceListView extends StatelessWidget {
  final List<PublicPrice> prices;

  const PublicPriceListView({super.key, required this.prices});

  @override
  Widget build(BuildContext context) {
    if (prices.isEmpty) {
      return Center(
        child: Text(
          'Veri bulunamadı',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ).animate().fadeIn();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      itemCount: prices.length,
      separatorBuilder: (_, __) =>
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
      itemBuilder: (context, index) {
        final price = prices[index];
        return _PublicPriceRow(
          price: price,
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }
}

class _PublicPriceRow extends StatelessWidget {
  final PublicPrice price;

  const _PublicPriceRow({required this.price});

  String _formatPrice(String priceVal) {
    if (priceVal.startsWith('\$') || priceVal.startsWith('€')) {
      return priceVal;
    }

    final cleanPrice = priceVal.replaceAll(',', '.');
    final numValue = double.tryParse(cleanPrice);
    if (numValue != null) {
      return '₺${NumberFormat('#,##0.00', 'tr_TR').format(numValue)}';
    }
    return priceVal;
  }

  @override
  Widget build(BuildContext context) {
    final changeValue = price.change.replaceAll('%', '').replaceAll(',', '.');
    final changeNum = double.tryParse(changeValue) ?? 0;
    final isPositive = changeNum >= 0;
    final changeColor = isPositive
        ? const Color(0xFF4ADE80)
        : const Color(0xFFF87171);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PublicPriceDetailScreen(price: price),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  Text(
                    price.code.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatPrice(price.buyPrice),
                    style: const TextStyle(
                      color: AppTheme.gold,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const Gap(4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        isPositive ? Iconsax.arrow_up_3 : Iconsax.arrow_down,
                        color: changeColor,
                        size: 12,
                      ),
                      const Gap(4),
                      Text(
                        price.change,
                        style: TextStyle(
                          color: changeColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(8),
            Icon(
              Iconsax.arrow_right_3,
              color: Colors.white.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
