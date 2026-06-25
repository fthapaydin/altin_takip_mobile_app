import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/utils/currency_input_formatter.dart';
import 'package:altin_takip/features/assets/presentation/asset_notifier.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';
import 'package:altin_takip/features/calculator/presentation/widgets/calculator_input_field.dart';
import 'package:altin_takip/features/calculator/presentation/widgets/calculator_currency_selector.dart';

/// Self-contained profit calculator tab, managing mathematical states locally.
class CalculatorProfitTab extends ConsumerStatefulWidget {
  const CalculatorProfitTab({super.key});

  @override
  ConsumerState<CalculatorProfitTab> createState() =>
      _CalculatorProfitTabState();
}

class _CalculatorProfitTabState extends ConsumerState<CalculatorProfitTab> {
  Currency? _profitCurrency;
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double _calculateProfit() {
    final buyPrice =
        double.tryParse(
          _buyPriceController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;
    final sellPrice =
        double.tryParse(
          _sellPriceController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;
    final amount =
        double.tryParse(
          _amountController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;
    return (sellPrice - buyPrice) * amount;
  }

  double _calculateProfitPercentage() {
    final buyPrice =
        double.tryParse(
          _buyPriceController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;
    final sellPrice =
        double.tryParse(
          _sellPriceController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;
    if (buyPrice == 0) return 0;
    return ((sellPrice - buyPrice) / buyPrice) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assetProvider);
    final currencies = state is AssetLoaded ? state.currencies : <Currency>[];

    final profit = _calculateProfit();
    final percentage = _calculateProfitPercentage();
    final isPositive = profit >= 0;
    final themeColor = isPositive
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    final buyPrice =
        double.tryParse(_buyPriceController.text.replaceAll(',', '.')) ?? 0;
    final sellPrice =
        double.tryParse(_sellPriceController.text.replaceAll(',', '.')) ?? 0;
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;

    final double topPadding = 164.0;

    final String amountSuffix = _profitCurrency != null
        ? _profitCurrency!.code.toUpperCase().replaceAll('_', ' ')
        : 'Birim';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24, topPadding, 24, 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Varlık Seçimi',
            style: GoogleFonts.ubuntu(
              color: AppTheme.gold,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(12),
          CalculatorCurrencySelector(
            selectedCurrency: _profitCurrency,
            currencies: currencies,
            label: 'Varlık Seçin',
            onSelected: (currency) {
              setState(() {
                _profitCurrency = currency;
                if (currency != null) {
                  final formatter = NumberFormat('#,##0.00', 'tr_TR');
                  _buyPriceController.text = formatter.format(currency.buying);
                  _sellPriceController.text = formatter.format(
                    currency.selling,
                  );
                }
              });
            },
          ),
          const Gap(24),
          Row(
            children: [
              Expanded(
                child: CalculatorInputField(
                  controller: _buyPriceController,
                  label: 'Alış Fiyatı',
                  hint: '0,00',
                  prefix: '₺',
                  formatters: [TurkishCurrencyFormatter()],
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const Gap(16),
              Expanded(
                child: CalculatorInputField(
                  controller: _sellPriceController,
                  label: 'Satış Fiyatı',
                  hint: '0,00',
                  prefix: '₺',
                  formatters: [TurkishCurrencyFormatter()],
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const Gap(16),
          CalculatorInputField(
            controller: _amountController,
            label: 'Miktar',
            hint: 'Örn: 5',
            suffix: amountSuffix,
            formatters: [TurkishCurrencyFormatter()],
            onChanged: (_) => setState(() {}),
          ),
          const Gap(32),
          _buildResultCard(
            profit,
            percentage,
            isPositive,
            themeColor,
            buyPrice,
            sellPrice,
            amount,
          ),
          const Gap(120),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildResultCard(
    double profit,
    double percentage,
    bool isPositive,
    Color themeColor,
    double buyPrice,
    double sellPrice,
    double amount,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Container(
                    width: 3.5,
                    height: 38,
                    decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isPositive ? Iconsax.trend_up : Iconsax.trend_down,
                            color: themeColor,
                            size: 16,
                          ),
                          const Gap(8),
                          Text(
                            isPositive ? 'Tahmini Kar' : 'Tahmini Zarar',
                            style: GoogleFonts.ubuntu(
                              color: themeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Gap(16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${isPositive ? '+' : ''}₺${NumberFormat('#,##0.00', 'tr_TR').format(profit)}',
                            style: GoogleFonts.ubuntu(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const Gap(12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: themeColor.withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${isPositive ? '+' : ''}%${NumberFormat('#,##0.00', 'tr_TR').format(percentage)}',
                              style: GoogleFonts.ubuntu(
                                color: themeColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (amount > 0) ...[
                        const Gap(20),
                        Divider(
                          color: Colors.white.withValues(alpha: 0.05),
                          height: 1,
                        ),
                        const Gap(16),
                        _buildProfitDetail(
                          'TOPLAM MALİYET',
                          '₺${NumberFormat('#,##0.00', 'tr_TR').format(buyPrice * amount)}',
                        ),
                        const Gap(8),
                        _buildProfitDetail(
                          'TOPLAM DEĞER',
                          '₺${NumberFormat('#,##0.00', 'tr_TR').format(sellPrice * amount)}',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildProfitDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.ubuntu(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.ubuntu(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
