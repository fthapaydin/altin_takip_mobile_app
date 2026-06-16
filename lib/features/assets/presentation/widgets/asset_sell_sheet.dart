import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:altin_takip/features/assets/presentation/asset_notifier.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';

class AssetSellSheet extends ConsumerStatefulWidget {
  final Asset asset;

  const AssetSellSheet({super.key, required this.asset});

  static void show(BuildContext context, Asset asset) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AssetSellSheet(asset: asset),
      ),
    );
  }

  @override
  ConsumerState<AssetSellSheet> createState() => _AssetSellSheetState();
}

class _AssetSellSheetState extends ConsumerState<AssetSellSheet> {
  final _amountController = TextEditingController();
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: (widget.asset.currency?.selling ?? widget.asset.price)
          .toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.read(assetProvider);
    double availableBalance = widget.asset.amount;
    if (state is AssetLoaded) {
      final sameCurrencyAssets = state.assets.where(
        (a) => a.currencyId == widget.asset.currencyId,
      );
      final totalBuys = sameCurrencyAssets
          .where((a) => a.type == 'buy')
          .fold<double>(0, (sum, a) => sum + a.amount);
      final totalSells = sameCurrencyAssets
          .where((a) => a.type == 'sell')
          .fold<double>(0, (sum, a) => sum + a.amount);
      availableBalance = totalBuys - totalSells;
    }

    final isGold = widget.asset.currency?.isGold == true;
    final themeColor = isGold ? AppTheme.gold : const Color(0xFF60A5FA);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1116),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1.0,
        ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Varlık Sat',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const Gap(4),
          Text(
            isGold
                ? (widget.asset.currency?.name ?? '')
                : (widget.asset.currency?.code ?? ''),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Gap(24),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Miktar',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
              hintText: 'Maks: ${_formatAmount(availableBalance)}',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 13),
              prefixIcon: Icon(Iconsax.weight, color: Colors.white.withValues(alpha: 0.4), size: 18),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.02),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: themeColor.withValues(alpha: 0.3), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
          ),
          const Gap(16),
          TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Satış Fiyatı',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
              prefixIcon: Icon(Iconsax.money, color: Colors.white.withValues(alpha: 0.4), size: 18),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.02),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: themeColor.withValues(alpha: 0.3), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
          ),
          const Gap(28),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeColor.withValues(alpha: 0.15),
                  themeColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: themeColor.withValues(alpha: 0.25),
                width: 1.2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _handleSell(context, ref, availableBalance),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'Satışı Onayla',
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Gap(16),
        ],
      ),
    );
  }

  void _handleSell(
    BuildContext context,
    WidgetRef ref,
    double availableBalance,
  ) {
    final amountText = _amountController.text.trim();
    final priceText = _priceController.text.trim();

    if (amountText.isEmpty) {
      AppNotification.show(
        context,
        message: 'Lütfen satılacak miktarı girin',
        type: NotificationType.error,
      );
      return;
    }

    if (priceText.isEmpty) {
      AppNotification.show(
        context,
        message: 'Lütfen satış fiyatını girin',
        type: NotificationType.error,
      );
      return;
    }

    final amount = double.tryParse(amountText.replaceAll(',', '.')) ?? 0;
    final price = double.tryParse(priceText.replaceAll(',', '.')) ?? 0;

    if (amount <= 0) {
      AppNotification.show(
        context,
        message: 'Miktar 0\'dan büyük olmalıdır',
        type: NotificationType.error,
      );
      return;
    }
    if (price <= 0) {
      AppNotification.show(
        context,
        message: 'Satış fiyatı 0\'dan büyük olmalıdır',
        type: NotificationType.error,
      );
      return;
    }
    if (amount > availableBalance) {
      AppNotification.show(
        context,
        message:
            'Mevcut miktardan fazla satamazsınız (Maks: ${_formatAmount(availableBalance)})',
        type: NotificationType.error,
      );
      return;
    }

    ref
        .read(assetProvider.notifier)
        .sellAssetById(
          currencyId: widget.asset.currencyId,
          amount: amount,
          price: price,
        );
    Navigator.pop(context);
    AppNotification.show(
      context,
      message: 'Satış işlemi kaydedildi',
      type: NotificationType.success,
    );
  }

  String _formatAmount(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return NumberFormat('#,##0.##', 'tr_TR').format(value);
  }
}
