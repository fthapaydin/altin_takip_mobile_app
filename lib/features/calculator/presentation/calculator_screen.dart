import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/assets/presentation/asset_notifier.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';
import 'package:intl/intl.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Converter state
  Currency? _fromCurrency;
  Currency? _toCurrency;
  final _converterController = TextEditingController();
  double _convertedValue = 0;

  // Profit Calculator state
  Currency? _profitCurrency;
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _converterController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _calculateConversion() {
    if (_fromCurrency == null) return;

    final amount =
        double.tryParse(_converterController.text.replaceAll(',', '.')) ?? 0;

    // Convert to TL first (using selling price)
    final tlValue = amount * _fromCurrency!.selling;

    if (_toCurrency == null) {
      // Just show TL value
      setState(() => _convertedValue = tlValue);
    } else {
      // Convert TL to target currency (using buying price)
      setState(() => _convertedValue = tlValue / _toCurrency!.buying);
    }
  }

  double _calculateProfit() {
    final buyPrice =
        double.tryParse(_buyPriceController.text.replaceAll(',', '.')) ?? 0;
    final sellPrice =
        double.tryParse(_sellPriceController.text.replaceAll(',', '.')) ?? 0;
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;

    return (sellPrice - buyPrice) * amount;
  }

  double _calculateProfitPercentage() {
    final buyPrice =
        double.tryParse(_buyPriceController.text.replaceAll(',', '.')) ?? 0;
    final sellPrice =
        double.tryParse(_sellPriceController.text.replaceAll(',', '.')) ?? 0;

    if (buyPrice == 0) return 0;
    return ((sellPrice - buyPrice) / buyPrice) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assetProvider);
    final currencies = state is AssetLoaded ? state.currencies : <Currency>[];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: const Text(
          'Hesaplama',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white70,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: AppTheme.gold,
                  borderRadius: BorderRadius.circular(30),
                ),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: 'Dönüştürücü'),
                  Tab(text: 'Kar/Zarar'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildConverterTab(currencies), _buildProfitTab(currencies)],
      ),
    );
  }

  Widget _buildConverterTab(List<Currency> currencies) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kaynak',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          _buildCurrencyDropdown(
            value: _fromCurrency,
            currencies: currencies,
            hint: 'Dönüştürülecek varlık',
            onChanged: (currency) {
              setState(() => _fromCurrency = currency);
              _calculateConversion();
            },
          ),
          const Gap(16),
          _buildInputField(
            controller: _converterController,
            label: 'Miktar',
            hint: 'Örn: 10',
            suffix: _fromCurrency?.name,
            onChanged: (_) => _calculateConversion(),
          ),
          const Gap(32),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.swap_vert_rounded,
                color: AppTheme.gold,
                size: 24,
              ),
            ),
          ),
          const Gap(32),
          const Text(
            'Hedef (Boş bırakılırsa TL)',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          _buildCurrencyDropdown(
            value: _toCurrency,
            currencies: currencies,
            hint: 'Hedef varlık (opsiyonel)',
            onChanged: (currency) {
              setState(() => _toCurrency = currency);
              _calculateConversion();
            },
            allowNull: true,
          ),
          const Gap(32),
          // Result Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.luxuryGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                Text(
                  'Sonuç',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const Gap(12),
                Text(
                  _toCurrency == null
                      ? '₺${NumberFormat('#,##0.00', 'tr_TR').format(_convertedValue)}'
                      : '${NumberFormat('#,##0.00', 'tr_TR').format(_convertedValue)} ${_toCurrency!.name}',
                  style: const TextStyle(
                    color: AppTheme.gold,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                if (_fromCurrency != null) ...[
                  const Gap(8),
                  Text(
                    '1 ${_fromCurrency!.name} = ₺${NumberFormat('#,##0.00', 'tr_TR').format(_fromCurrency!.selling)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitTab(List<Currency> currencies) {
    final profit = _calculateProfit();
    final percentage = _calculateProfitPercentage();
    final isPositive = profit >= 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Varlık',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          _buildCurrencyDropdown(
            value: _profitCurrency,
            currencies: currencies,
            hint: 'Varlık seçin',
            onChanged: (currency) {
              setState(() {
                _profitCurrency = currency;
                if (currency != null) {
                  _buyPriceController.text = currency.buying.toStringAsFixed(2);
                  _sellPriceController.text = currency.selling.toStringAsFixed(
                    2,
                  );
                }
              });
            },
          ),
          const Gap(24),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _buyPriceController,
                  label: 'Alış Fiyatı',
                  hint: '0.00',
                  prefix: '₺',
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const Gap(16),
              Expanded(
                child: _buildInputField(
                  controller: _sellPriceController,
                  label: 'Satış Fiyatı',
                  hint: '0.00',
                  prefix: '₺',
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const Gap(16),
          _buildInputField(
            controller: _amountController,
            label: 'Miktar',
            hint: 'Örn: 5',
            suffix: _profitCurrency?.name ?? 'adet',
            onChanged: (_) => setState(() {}),
          ),
          const Gap(32),
          // Result Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.luxuryGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color: isPositive
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFFF87171),
                      size: 28,
                    ),
                    const Gap(8),
                    Text(
                      isPositive ? 'Kar' : 'Zarar',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                Text(
                  '${isPositive ? '+' : ''}₺${NumberFormat('#,##0.00', 'tr_TR').format(profit)}',
                  style: TextStyle(
                    color: isPositive
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFFF87171),
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const Gap(8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isPositive
                                ? const Color(0xFF4ADE80)
                                : const Color(0xFFF87171))
                            .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}%${NumberFormat('#,##0.00', 'tr_TR').format(percentage)}',
                    style: TextStyle(
                      color: isPositive
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFFF87171),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(100), // Space for navbar
        ],
      ),
    );
  }

  Widget _buildCurrencyDropdown({
    required Currency? value,
    required List<Currency> currencies,
    required String hint,
    required ValueChanged<Currency?> onChanged,
    bool allowNull = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Currency>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.white.withOpacity(0.4)),
          ),
          isExpanded: true,
          dropdownColor: AppTheme.surface,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white.withOpacity(0.4),
          ),
          items: [
            if (allowNull)
              DropdownMenuItem<Currency>(
                value: null,
                child: Text(
                  'Türk Lirası (TL)',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ),
            ...currencies.map(
              (c) => DropdownMenuItem(
                value: c,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          c.code.length >= 2 ? c.code.substring(0, 2) : c.code,
                          style: const TextStyle(
                            color: AppTheme.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        c.isGold ? c.name : c.code,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? prefix,
    String? suffix,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
            ],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              prefixText: prefix != null ? '$prefix ' : null,
              prefixStyle: const TextStyle(
                color: AppTheme.gold,
                fontWeight: FontWeight.bold,
              ),
              suffixText: suffix,
              suffixStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
