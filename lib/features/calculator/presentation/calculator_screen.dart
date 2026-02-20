import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/assets/presentation/asset_notifier.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';
import 'package:altin_takip/core/widgets/currency_icon.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/utils/currency_input_formatter.dart';
import 'package:altin_takip/core/widgets/app_bar_widget.dart';

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

  bool _initialDefaultSet = false;

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
    final amountText = _converterController.text
        .replaceAll('.', '')
        .replaceAll(',', '.');
    final amount = double.tryParse(amountText) ?? 0;

    // Convert to TL first (using selling price if asset, or just the amount if TL)
    final tlValue = _fromCurrency == null
        ? amount
        : amount * _fromCurrency!.selling;

    if (_toCurrency == null) {
      // Just show TL value
      setState(() => _convertedValue = tlValue);
    } else {
      // Convert TL to target currency (using buying price)
      setState(() => _convertedValue = tlValue / _toCurrency!.buying);
    }
  }

  double _calculateProfit() {
    final buyPriceStr = _buyPriceController.text
        .replaceAll('.', '')
        .replaceAll(',', '.');
    final sellPriceStr = _sellPriceController.text
        .replaceAll('.', '')
        .replaceAll(',', '.');
    final amountStr = _amountController.text
        .replaceAll('.', '')
        .replaceAll(',', '.');

    final buyPrice = double.tryParse(buyPriceStr) ?? 0;
    final sellPrice = double.tryParse(sellPriceStr) ?? 0;
    final amount = double.tryParse(amountStr) ?? 0;

    return (sellPrice - buyPrice) * amount;
  }

  double _calculateProfitPercentage() {
    final buyPriceStr = _buyPriceController.text
        .replaceAll('.', '')
        .replaceAll(',', '.');
    final sellPriceStr = _sellPriceController.text
        .replaceAll('.', '')
        .replaceAll(',', '.');

    final buyPrice = double.tryParse(buyPriceStr) ?? 0;
    final sellPrice = double.tryParse(sellPriceStr) ?? 0;

    if (buyPrice == 0) return 0;
    return ((sellPrice - buyPrice) / buyPrice) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assetProvider);
    final currencies = state is AssetLoaded ? state.currencies : <Currency>[];

    // Set default from currency if none selected and currencies are available (Only Once)
    if (!_initialDefaultSet && _fromCurrency == null && currencies.isNotEmpty) {
      _fromCurrency = currencies.firstWhere(
        (c) => c.code.toLowerCase() == 'usd',
        orElse: () => currencies.first,
      );
      _initialDefaultSet = true;
      _calculateConversion();
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBarWidget(
        title: 'Hesaplama',
        showBack: false,
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
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
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
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'KAYNAK',
            style: TextStyle(
              color: AppTheme.gold,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const Gap(12),
          _buildSelectionCard(
            selectedCurrency: _fromCurrency,
            currencies: currencies,
            label: 'Dönüştürülecek Varlık',
            allowNull: true,
            onSelected: (currency) {
              setState(() => _fromCurrency = currency);
              _calculateConversion();
            },
            currentSelection: _fromCurrency,
          ),
          const Gap(16),
          _buildInputField(
            controller: _converterController,
            label: 'Miktar',
            hint: 'Eklenecek miktar',
            suffix: _fromCurrency?.name,
            formatters: [TurkishCurrencyFormatter()],
            onChanged: (_) => _calculateConversion(),
          ),
          const Gap(32),
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
                  color: AppTheme.gold.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.swap_vert_rounded,
                  color: AppTheme.gold,
                  size: 24,
                ),
              ),
            ),
          ).animate().rotate(duration: 400.ms),
          const Gap(32),
          const Text(
            'HEDEF (BOŞ BIRAKILIRSA TL)',
            style: TextStyle(
              color: AppTheme.gold,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const Gap(12),
          _buildSelectionCard(
            selectedCurrency: _toCurrency,
            currencies: currencies,
            label: 'Hedef Varlık (Opsiyonel)',
            allowNull: true,
            onSelected: (currency) {
              setState(() => _toCurrency = currency);
              _calculateConversion();
            },
            currentSelection: _toCurrency,
          ),
          const Gap(32),
          // Result Card - Modern Stealth Fintech Style
          Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
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
                    // Minimalist Top Label
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Tahmin Edilen Değer'.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const Gap(24),
                    // Main Result Amount
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w200, // Light and sleek
                              letterSpacing: -1.5,
                            ),
                          ),
                          const Gap(10),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              _toCurrency?.code ?? 'TRY',
                              style: const TextStyle(
                                color: AppTheme.gold,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    Text(
                      _toCurrency?.name ?? 'Türk Lirası',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (_fromCurrency != null) ...[
                      const Gap(32),
                      // Modern Rate Breakdown Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.03),
                          ),
                        ),
                        child: Row(
                          children: [
                            CurrencyIcon(
                              iconUrl: _fromCurrency!.iconUrl,
                              isGold: _fromCurrency!.isGold,
                              size: 24,
                            ),
                            const Gap(12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'GÜNCEL KUR',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.gold.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '₺${NumberFormat('#,##0.00', 'tr_TR').format(_fromCurrency!.selling)}',
                                style: const TextStyle(
                                  color: AppTheme.gold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
          const Gap(120),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
    );
  }

  Widget _buildProfitTab(List<Currency> currencies) {
    final profit = _calculateProfit();
    final percentage = _calculateProfitPercentage();
    final isPositive = profit >= 0;

    final buyPrice =
        double.tryParse(_buyPriceController.text.replaceAll(',', '.')) ?? 0;
    final sellPrice =
        double.tryParse(_sellPriceController.text.replaceAll(',', '.')) ?? 0;
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VARLIK SEÇİMİ',
            style: TextStyle(
              color: AppTheme.gold,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const Gap(12),
          _buildSelectionCard(
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
            currentSelection: _profitCurrency,
          ),
          const Gap(24),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
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
                child: _buildInputField(
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
          _buildInputField(
            controller: _amountController,
            label: 'Miktar',
            hint: 'Örn: 5',
            suffix: _profitCurrency?.name ?? 'Birim',
            formatters: [TurkishCurrencyFormatter()],
            onChanged: (_) => setState(() {}),
          ),
          const Gap(32),
          // Profit Result Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (isPositive ? Colors.green : Colors.red).withValues(
                    alpha: 0.1,
                  ),
                  AppTheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: (isPositive ? Colors.green : Colors.red).withValues(
                  alpha: 0.2,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color: isPositive ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const Gap(8),
                    Text(
                      isPositive ? 'TAHMİNİ KAR' : 'TAHMİNİ ZARAR',
                      style: TextStyle(
                        color: (isPositive ? Colors.green : Colors.red)
                            .withValues(alpha: 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                Text(
                  '${isPositive ? '+' : ''}₺${NumberFormat('#,##0.00', 'tr_TR').format(profit)}',
                  style: TextStyle(
                    color: isPositive ? Colors.white : Colors.red,
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Gap(12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : Colors.red).withValues(
                      alpha: 0.15,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}%${NumberFormat('#,##0.00', 'tr_TR').format(percentage)}',
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (amount > 0) ...[
                  const Gap(24),
                  Divider(
                    color: Colors.white.withValues(alpha: 0.05),
                    height: 1,
                  ),
                  const Gap(24),
                  _buildProfitDetail(
                    'TOPLAM MALİYET',
                    '₺${NumberFormat('#,##0.00', 'tr_TR').format(buyPrice * amount)}',
                  ),
                  const Gap(12),
                  _buildProfitDetail(
                    'TOPLAM DEĞER',
                    '₺${NumberFormat('#,##0.00', 'tr_TR').format(sellPrice * amount)}',
                  ),
                ],
              ],
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          const Gap(120),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildProfitDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionCard({
    required Currency? selectedCurrency,
    required List<Currency> currencies,
    required String label,
    required ValueChanged<Currency?> onSelected,
    Currency? currentSelection,
    bool allowNull = false,
  }) {
    return InkWell(
      onTap: () => _showCurrencyPicker(
        context: context,
        currencies: currencies,
        onSelected: onSelected,
        currentSelection: currentSelection,
        allowNull: allowNull,
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            if (selectedCurrency == null && allowNull)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.currency_lira, color: AppTheme.gold),
              )
            else if (selectedCurrency != null)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: CurrencyIcon(
                  iconUrl: selectedCurrency.iconUrl,
                  isGold: selectedCurrency.isGold,
                  size: 24,
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.help_outline, color: Colors.white38),
              ),
            const Gap(16),
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
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (selectedCurrency != null)
                    Text(
                      'Canlı Değer: ₺${NumberFormat('#,##0.00', 'tr_TR').format(selectedCurrency.selling)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker({
    required BuildContext context,
    required List<Currency> currencies,
    required ValueChanged<Currency?> onSelected,
    Currency? currentSelection,
    bool allowNull = false,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final goldCurrencies = currencies.where((c) => c.isGold).toList();
        final forexCurrencies = currencies.where((c) => !c.isGold).toList();

        // Determine which tab to open:
        // 0: Gold (default or if selected asset is gold/null)
        // 1: Forex (if selected asset is forex)
        final initialIdx =
            (currentSelection != null && !currentSelection.isGold) ? 1 : 0;

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                const Gap(24),
                const Text(
                  'Varlık Seçimi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const Gap(20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
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
                        fontWeight: FontWeight.w400,
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
                        currencies: goldCurrencies,
                        onSelected: onSelected,
                        allowNull: allowNull,
                        showTL: true,
                      ),
                      _buildPickerList(
                        currencies: forexCurrencies,
                        onSelected: onSelected,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerList({
    required List<Currency> currencies,
    required ValueChanged<Currency?> onSelected,
    bool allowNull = false,
    bool showTL = false,
  }) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: [
        if (showTL && allowNull) ...[
          _buildPickerItem(
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
            title: c.name,
            subtitle:
                'Satış: ₺${NumberFormat('#,##0.00', 'tr_TR').format(c.selling)}',
            icon: CurrencyIcon(iconUrl: c.iconUrl, isGold: c.isGold, size: 24),
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
    required String title,
    required String subtitle,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: switch (icon) {
                    CurrencyIcon ci => CurrencyIcon(
                      iconUrl: ci.iconUrl,
                      isGold: ci.isGold,
                      size: 48,
                    ),
                    _ => icon,
                  },
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.2),
                size: 20,
              ),
            ],
          ),
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
    List<TextInputFormatter>? formatters,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const Gap(10),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              if (formatters != null) ...formatters,
            ],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.15),
                fontSize: 15,
              ),
              prefixText: prefix != null ? '$prefix ' : null,
              prefixStyle: const TextStyle(
                color: AppTheme.gold,
                fontWeight: FontWeight.w400,
              ),
              suffixText: suffix,
              suffixStyle: const TextStyle(
                color: AppTheme.gold,
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
