import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/assets/presentation/add_asset_screen.dart';

/// Banner notifying the user that they do not have transaction logs in the selected asset.
class CurrencyHistoryEmptyState extends StatelessWidget {
  final String currencyCode;

  const CurrencyHistoryEmptyState({super.key, required this.currencyCode});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Iconsax.receipt_1,
            size: 32,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        const Gap(16),
        Text(
          'İşlem Geçmişi Yok',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const Gap(4),
        Text(
          'Bu varlık için henüz işlem kaydınız bulunmuyor.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const Gap(24),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddAssetScreen(initialCurrencyCode: currencyCode),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            foregroundColor: AppTheme.gold,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.add_circle, size: 18),
              Gap(8),
              Text('İşlem Ekle'),
            ],
          ),
        ),
      ],
    );
  }
}
