import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/widgets/currency_icon.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';

/// Card selector that opens a styled bottom sheet to choose currency.
class CalculatorCurrencySelector extends StatelessWidget {
  final Currency? selectedCurrency;
  final List<Currency> currencies;
  final String label;
  final ValueChanged<Currency?> onSelected;
  final bool allowNull;

  const CalculatorCurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.currencies,
    required this.label,
    required this.onSelected,
    this.allowNull = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showCurrencyPicker(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedCurrency == null && allowNull
                        ? 'Türk Lirası'
                        : selectedCurrency?.name ?? 'Varlık Seçin',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(2),
                  Text(
                    selectedCurrency != null
                        ? 'Canlı Değer: ₺${NumberFormat('#,##0.00', 'tr_TR').format(selectedCurrency!.selling)}'
                        : 'Baz Para Birimi',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_down_1,
              color: Colors.white.withValues(alpha: 0.4),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    final goldCurrencies = currencies.where((c) => c.isGold).toList();
    final forexCurrencies = currencies.where((c) => !c.isGold).toList();
    final initialIdx = (selectedCurrency != null && !selectedCurrency!.isGold) ? 1 : 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: AppTheme.background.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1.0,
                  ),
                ),
              ),
              child: DefaultTabController(
                length: 2,
                initialIndex: initialIdx,
                child: Column(
                  children: [
                    const Gap(12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Gap(16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Varlık Seçimi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.5,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white70,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                            width: 1.0,
                          ),
                        ),
                        child: TabBar(
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: AppTheme.gold,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.white38,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          tabs: const [
                            Tab(text: 'ALTIN'),
                            Tab(text: 'DÖVİZ'),
                          ],
                        ),
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildPickerList(
                            context: context,
                            currencies: goldCurrencies,
                            allowNull: allowNull,
                            showTL: true,
                          ),
                          _buildPickerList(
                            context: context,
                            currencies: forexCurrencies,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerList({
    required BuildContext context,
    required List<Currency> currencies,
    bool allowNull = false,
    bool showTL = false,
  }) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: [
        if (showTL && allowNull) ...[
          _buildPickerItem(
            context: context,
            title: 'Türk Lirası',
            subtitle: 'Baz Para Birimi',
            icon: const Icon(Icons.currency_lira, color: AppTheme.gold),
            onTap: () {
              onSelected(null);
              Navigator.pop(context);
            },
          ),
          const Gap(12),
        ],
        ...currencies.map(
          (c) => _buildPickerItem(
            context: context,
            title: c.name,
            subtitle: 'Satış: ₺${NumberFormat('#,##0.00', 'tr_TR').format(c.selling)}',
            icon: CurrencyIcon(iconUrl: null, isGold: c.isGold, size: 24),
            onTap: () {
              onSelected(c);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPickerItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Iconsax.arrow_right_3,
                color: Colors.white.withValues(alpha: 0.2),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
