import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/widgets/currency_icon.dart';
import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:altin_takip/features/assets/presentation/asset_notifier.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/assets/presentation/widgets/asset_sell_sheet.dart';
import 'package:altin_takip/features/assets/presentation/widgets/asset_delete_sheet.dart';

class AssetOptionsSheet extends ConsumerWidget {
  final Asset asset;

  const AssetOptionsSheet({super.key, required this.asset});

  static void show(BuildContext context, Asset asset) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AssetOptionsSheet(asset: asset),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.read(assetProvider);
    double availableBalance = 0;
    if (state is AssetLoaded) {
      final sameCurrencyAssets = state.assets.where(
        (a) => a.currencyId == asset.currencyId,
      );
      final totalBuys = sameCurrencyAssets
          .where((a) => a.type == 'buy')
          .fold<double>(0, (sum, a) => sum + a.amount);
      final totalSells = sameCurrencyAssets
          .where((a) => a.type == 'sell')
          .fold<double>(0, (sum, a) => sum + a.amount);
      availableBalance = totalBuys - totalSells;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 40, spreadRadius: 10),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(24),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.gold.withOpacity(0.2),
                      AppTheme.gold.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
                ),
                child: CurrencyIcon(
                  iconUrl: asset.currency?.iconUrl,
                  isGold: asset.currency?.isGold == true,
                  color: AppTheme.gold,
                  size: 40,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCurrencyDisplayName(asset),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '${_formatAmount(asset.amount)} adet • ₺${NumberFormat('#,##0.00', 'tr_TR').format(asset.price)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(32),
          if (asset.type == 'buy' && availableBalance > 0) ...[
            _buildActionTile(
              icon: Iconsax.money_send,
              label: 'Sat',
              subtitle: 'Bu varlığı satışa çıkar',
              onTap: () {
                Navigator.pop(context);
                AssetSellSheet.show(context, asset);
              },
            ),
            const Gap(12),
          ],
          _buildActionTile(
            icon: Iconsax.trash,
            label: 'Sil',
            subtitle: 'Bu kaydı kalıcı olarak sil',
            isDestructive: true,
            onTap: () {
              Navigator.pop(context);
              AssetDeleteSheet.show(context, asset);
            },
          ),
          const Gap(20),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDestructive ? Colors.red : AppTheme.gold).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : AppTheme.gold,
                size: 22,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDestructive ? Colors.red : Colors.white,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              color: Colors.white.withValues(alpha: 0.2),
              size: 24,
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

  String _getCurrencyDisplayName(Asset asset) {
    final currency = asset.currency;
    if (currency == null) return 'Varlık';
    return currency.isGold ? currency.name : currency.code;
  }
}
