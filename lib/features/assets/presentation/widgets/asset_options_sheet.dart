import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
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

    final isGold = asset.currency?.isGold == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1116),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 32,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(22),
          Row(
            children: [
              // Sleek vertical category indicator instead of avatar
              Container(
                width: 3.5,
                height: 38,
                decoration: BoxDecoration(
                  color: isGold ? AppTheme.gold : const Color(0xFF60A5FA),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCurrencyDisplayName(asset),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const Gap(3),
                    Text(
                      '${_formatAmount(asset.amount)} adet  •  ₺${NumberFormat('#,##0.00', 'tr_TR').format(asset.price)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(28),
          if (asset.type == 'buy' && availableBalance > 0) ...[
            _ActionTile(
              icon: Iconsax.money_send,
              label: 'Sat',
              subtitle: 'Bu varlığı satışa çıkar',
              isGold: isGold,
              onTap: () {
                Navigator.pop(context);
                AssetSellSheet.show(context, asset);
              },
            ),
            const Gap(12),
          ],
          _ActionTile(
            icon: Iconsax.trash,
            label: 'Sil',
            subtitle: 'Bu kaydı kalıcı olarak sil',
            isDestructive: true,
            isGold: isGold,
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

class _ActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isGold;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    required this.isGold,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.isDestructive
        ? const Color(0xFFF87171)
        : (widget.isGold ? AppTheme.gold : const Color(0xFF60A5FA));

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: _isPressed ? 0.8 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: themeColor.withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    color: themeColor,
                    size: 20,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: widget.isDestructive ? const Color(0xFFF87171) : Colors.white,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Iconsax.arrow_right_3,
                  color: Colors.white.withValues(alpha: 0.25),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
