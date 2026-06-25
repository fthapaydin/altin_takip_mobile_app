import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/notifications/domain/notification.dart' as domain;

/// List of grouped assets showing values and changes in notification details.
class NotificationAssetsList extends StatelessWidget {
  final List<domain.NotificationAsset> assets;

  const NotificationAssetsList({super.key, required this.assets});

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) return const SizedBox.shrink();

    final grouped = _groupAssets(assets);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VARLIK DETAYLARI',
          style: TextStyle(
            color: AppTheme.gold.withValues(alpha: 0.8),
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
        const Gap(16),
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: grouped.length,
          separatorBuilder: (_, __) => const Gap(12),
          itemBuilder: (context, index) {
            final asset = grouped[index];
            final isAssetPositive = asset.changePercentage >= 0;
            final isGoldAsset = asset.currencyCode.toLowerCase().contains('altin') ||
                asset.currencyCode.toLowerCase().contains('xau') ||
                asset.currencyName.toLowerCase().contains('altin') ||
                asset.currencyName.toLowerCase().contains('gold');
            final themeColor = isGoldAsset ? AppTheme.gold : const Color(0xFF4C82F7);

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Dynamic Category Avatar Container
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: themeColor.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      isGoldAsset ? Iconsax.coin_1 : Iconsax.dollar_circle,
                      color: themeColor,
                      size: 20,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.currencyName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          '${asset.amount % 1 == 0 ? asset.amount.toInt() : asset.amount} Adet',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₺${NumberFormat('#,##0.00', 'tr_TR').format(asset.currentValue)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const Gap(2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${isAssetPositive ? '+' : ''}${NumberFormat('#,##0.00', 'tr_TR').format(asset.changeAmount)} ₺',
                            style: TextStyle(
                              color: isAssetPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            '(${isAssetPositive ? '+' : ''}%${asset.changePercentage.toStringAsFixed(2)})',
                            style: TextStyle(
                              color: isAssetPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  List<domain.NotificationAsset> _groupAssets(List<domain.NotificationAsset> assets) {
    final Map<String, domain.NotificationAsset> groups = {};

    for (final asset in assets) {
      if (groups.containsKey(asset.currencyCode)) {
        final current = groups[asset.currencyCode]!;
        final totalStartValue = current.startValue + asset.startValue;
        final totalCurrentValue = current.currentValue + asset.currentValue;

        final newChangePercentage = totalStartValue != 0
            ? ((totalCurrentValue - totalStartValue) / totalStartValue) * 100
            : 0.0;

        groups[asset.currencyCode] = domain.NotificationAsset(
          amount: current.amount + asset.amount,
          iconUrl: current.iconUrl,
          startPrice: current.startPrice,
          startValue: totalStartValue,
          changeAmount: current.changeAmount + asset.changeAmount,
          currencyCode: current.currencyCode,
          currencyName: current.currencyName,
          currentPrice: current.currentPrice,
          currentValue: totalCurrentValue,
          changePercentage: newChangePercentage,
        );
      } else {
        groups[asset.currencyCode] = asset;
      }
    }

    return groups.values.toList();
  }
}
