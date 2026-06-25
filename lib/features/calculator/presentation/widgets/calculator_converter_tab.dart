import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/widgets/currency_icon.dart';
import 'package:altin_takip/core/widgets/app_bar_widget.dart';
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
  ConsumerState<CalculatorConverterTab> createState() => _CalculatorConverterTabState();
}

class _CalculatorConverterTabState extends ConsumerState<CalculatorConverterTab> {
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
    final amountText = _converterController.text.replaceAll('.', '').replaceAll(',', '.');
    final amount = double.tryParse(amountText) ?? 0;

    final tlValue = _fromCurrency == null ? amount : amount * _fromCurrency!.selling;

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

    final double topPadding = MediaQuery.of(context).padding.top +
        AppBarWidget.getExpandedHeight(isLargeTitle: false) +
        48.0 + 16.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24, topPadding, 24, 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'KAYNAK',
            style: TextStyle(
              color: AppTheme.gold,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
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
            suffix: _fromCurrency?.name,
            formatters: [TurkishCurrencyFormatter()],
            onChanged: (_) => _calculateConversion(),
          ),
          const Gap(24),
          Center(
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
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.gold.withValues(alpha: 0.15),
                    width: 1.0,
                  ),
                ),
                child: const Icon(Icons.swap_vert_rounded, color: AppTheme.gold, size: 22),
              ),
            ),
          ).animate().rotate(duration: 400.ms),
          const Gap(24),
          const Text(
            'HEDEF (BOŞ BIRAKILIRSA TL)',
            style: TextStyle(
              color: AppTheme.gold,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
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
          _buildResultCard(),
          const Gap(120),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F1116), Color(0xFF09090A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'TAHMİN EDİLEN DEĞER',
              style: TextStyle(
                color: AppTheme.gold.withValues(alpha: 0.8),
                fontSize: 9,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
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
                  NumberFormat('#,##0.00', 'tr_TR').format(_convertedValue),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -1.0,
                  ),
                ),
                const Gap(8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    _toCurrency?.code ?? 'TRY',
                    style: const TextStyle(
                      color: AppTheme.gold,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(6),
          Text(
            _toCurrency?.name ?? 'Türk Lirası',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (_fromCurrency != null) ...[
            const Gap(24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.01),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
              ),
              child: Row(
                children: [
                  CurrencyIcon(iconUrl: null, isGold: _fromCurrency!.isGold, size: 24),
                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GÜNCEL KUR',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        '1 ${_fromCurrency!.name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '₺${NumberFormat('#,##0.00', 'tr_TR').format(_fromCurrency!.selling)}',
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }
}
