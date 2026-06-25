import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/widgets/currency_icon.dart';
import 'package:altin_takip/core/utils/currency_input_formatter.dart';
import 'package:altin_takip/features/assets/presentation/asset_notifier.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';
import 'package:altin_takip/features/calculator/presentation/widgets/calculator_input_field.dart';
import 'package:altin_takip/features/calculator/presentation/widgets/calculator_currency_selector.dart';

/// Self-contained converter tab, managing conversion state and arithmetic internally.
class CalculatorConverterTab extends ConsumerStatefulWidget {
  const CalculatorConverterTab({super.key});

  @override
  ConsumerState<CalculatorConverterTab> createState() =>
      _CalculatorConverterTabState();
}

class _CalculatorConverterTabState
    extends ConsumerState<CalculatorConverterTab> {
  Currency? _fromCurrency;
  Currency? _toCurrency;
  final _converterController = TextEditingController();
  double _convertedValue = 0;
  bool _initialDefaultSet = false;

  @override
  void dispose() {
    _converterController.dispose();
    super.dispose();
  }

  void _calculateConversion() {
    final amountText = _converterController.text
        .replaceAll('.', '')
        .replaceAll(',', '.');
    final amount = double.tryParse(amountText) ?? 0;

    final tlValue = _fromCurrency == null
        ? amount
        : amount * _fromCurrency!.selling;

    if (_toCurrency == null) {
      setState(() => _convertedValue = tlValue);
    } else {
      setState(() => _convertedValue = tlValue / _toCurrency!.buying);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assetProvider);
    final currencies = state is AssetLoaded ? state.currencies : <Currency>[];

    if (!_initialDefaultSet && _fromCurrency == null && currencies.isNotEmpty) {
      _fromCurrency = currencies.firstWhere(
        (c) => c.code.toLowerCase() == 'usd',
        orElse: () => currencies.first,
      );
      _initialDefaultSet = true;
      _calculateConversion();
    }

    final double topPadding = 164.0;

    // Formatting target code
    final String targetCode = (_toCurrency?.code ?? 'TRY')
        .replaceAll('_', ' ')
        .toUpperCase();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24, topPadding, 24, 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kaynak',
            style: GoogleFonts.ubuntu(
              color: AppTheme.gold.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(12),
          CalculatorCurrencySelector(
            selectedCurrency: _fromCurrency,
            currencies: currencies,
            label: 'Dönüştürülecek Varlık',
            allowNull: true,
            onSelected: (currency) {
              setState(() => _fromCurrency = currency);
              _calculateConversion();
            },
          ),
          const Gap(16),
          CalculatorInputField(
            controller: _converterController,
            label: 'Miktar',
            hint: 'Eklenecek miktar',
            suffix: _fromCurrency != null
                ? _fromCurrency!.code.toUpperCase().replaceAll('_', ' ')
                : 'TRY',
            formatters: [TurkishCurrencyFormatter()],
            onChanged: (_) => _calculateConversion(),
          ),
          const Gap(24),
          Center(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.gold.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.gold.withValues(alpha: 0.3),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gold.withValues(alpha: 0.08),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      final temp = _fromCurrency;
                      _fromCurrency = _toCurrency;
                      _toCurrency = temp;
                    });
                    _calculateConversion();
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.swap_vert_rounded,
                      color: AppTheme.gold,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ).animate().rotate(duration: 400.ms),
          const Gap(24),
          Text(
            'Hedef (Boş bırakılırsa TL)',
            style: GoogleFonts.ubuntu(
              color: AppTheme.gold.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(12),
          CalculatorCurrencySelector(
            selectedCurrency: _toCurrency,
            currencies: currencies,
            label: 'Hedef Varlık (Opsiyonel)',
            allowNull: true,
            onSelected: (currency) {
              setState(() => _toCurrency = currency);
              _calculateConversion();
            },
          ),
          const Gap(32),
          _buildResultCard(targetCode),
          const Gap(120),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
    );
  }

  Widget _buildResultCard(String targetCode) {
    return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(32),
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
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Text(
                        'Tahmin Edilen Değer',
                        style: GoogleFonts.ubuntu(
                          color: AppTheme.gold.withValues(alpha: 0.85),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Gap(24),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            NumberFormat(
                              '#,##0.00',
                              'tr_TR',
                            ).format(_convertedValue),
                            style: GoogleFonts.ubuntu(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(6),
                    Text(
                      _toCurrency?.name ?? 'Türk Lirası',
                      style: GoogleFonts.ubuntu(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (_fromCurrency != null) ...[
                      const Gap(28),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.01),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.03),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              CurrencyIcon(
                                iconUrl: null,
                                isGold: _fromCurrency!.isGold,
                                size: 24,
                              ),
                              const Gap(12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Güncel Kur',
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      fontSize: 8,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Gap(2),
                                  Text(
                                    '1 ${_fromCurrency!.name}',
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.gold.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '₺${NumberFormat('#,##0.00', 'tr_TR').format(_fromCurrency!.selling)}',
                                  style: GoogleFonts.ubuntu(
                                    color: AppTheme.gold,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }
}
