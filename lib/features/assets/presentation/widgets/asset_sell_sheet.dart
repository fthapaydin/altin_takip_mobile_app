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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Varlık Sat',
                style: TextStyle(
                  fontWeight: FontWeight.w400, // No bold
                  fontSize: 16, // Elegant size
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Iconsax.close_circle),
              ),
            ],
          ),
          const Gap(8),
          Text(
            widget.asset.currency?.isGold == true
                ? (widget.asset.currency?.name ?? '')
                : (widget.asset.currency?.code ?? ''),
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Gap(24),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Miktar',
              hintText: 'Maks: ${_formatAmount(availableBalance)}',
              prefixIcon: const Icon(Iconsax.weight),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const Gap(16),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Satış Fiyatı',
              prefixIcon: const Icon(Iconsax.money),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const Gap(32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleSell(context, ref, availableBalance),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold.withOpacity(0.1),
                foregroundColor: AppTheme.gold,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppTheme.gold.withOpacity(0.2)),
                ),
              ),
              child: const Text(
                'Satışı Onayla',
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
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
