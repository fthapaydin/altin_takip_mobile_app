import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/widgets/currency_icon.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';

/// Card selector that opens a styled bottom sheet to choose currency, styled with glassmorphism and Ubuntu typography.
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
    final bool isTL = selectedCurrency == null && allowNull;
    final Widget leadingIcon = isTL
        ? const Icon(Icons.currency_lira, color: AppTheme.gold, size: 20)
        : (selectedCurrency != null
            ? CurrencyIcon(iconUrl: null, isGold: selectedCurrency!.isGold, size: 20)
            : const Icon(Iconsax.wallet_3, color: AppTheme.gold, size: 20));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showCurrencyPicker(context),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Row(
                  children: [
                    // Icon Container
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: leadingIcon,
                    ),
                    const Gap(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTL ? 'Türk Lirası' : selectedCurrency?.name ?? 'Varlık Seçin',
                            style: GoogleFonts.ubuntu(
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
                                : 'Baz Para Birimi (TRY)',
                            style: GoogleFonts.ubuntu(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Iconsax.arrow_down_1,
                      color: Colors.white.withValues(alpha: 0.45),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                          Text(
                            'Varlık Seçimi',
                            style: GoogleFonts.ubuntu(
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                                gradient: AppTheme.goldGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.white38,
                              labelStyle: GoogleFonts.ubuntu(
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  icon,
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.ubuntu(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          subtitle,
                          style: GoogleFonts.ubuntu(
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
        ),
      ),
    );
  }
}
