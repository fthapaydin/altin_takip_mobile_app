import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/assets/presentation/asset_notifier.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/features/dashboard/presentation/transactions_screen.dart';

class AddAssetScreen extends ConsumerStatefulWidget {
  final String? initialCurrencyCode;

  const AddAssetScreen({super.key, this.initialCurrencyCode});

  @override
  ConsumerState<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends ConsumerState<AddAssetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Currency? _selectedCurrency;
  bool _isBuy = true;
  bool _isLoading = false;
  final _amountForDisplayController = TextEditingController();
  final _priceForDisplayController = TextEditingController();
  final _placeController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  List<Currency> _goldCurrencies = [];
  List<Currency> _forexCurrencies = [];

  // Number formatters
  final _currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrencies();
    });
  }

  void _loadCurrencies() {
    final state = ref.read(assetProvider);
    if (state is AssetLoaded) {
      setState(() {
        _goldCurrencies = state.currencies.where((c) => c.isGold).toList();
        _forexCurrencies = state.currencies.where((c) => !c.isGold).toList();
        _selectFirstCurrency();
      });
    }
  }

  void _selectFirstCurrency() {
    if (widget.initialCurrencyCode != null && _selectedCurrency == null) {
      // Check Gold first
      final goldMatch = _goldCurrencies.where(
        (c) => c.code == widget.initialCurrencyCode,
      );
      if (goldMatch.isNotEmpty) {
        _tabController.animateTo(0);
        _selectedCurrency = goldMatch.first;
        _updatePriceField();
        return;
      }

      // Check Forex
      final forexMatch = _forexCurrencies.where(
        (c) => c.code == widget.initialCurrencyCode,
      );
      if (forexMatch.isNotEmpty) {
        _tabController.animateTo(1);
        _selectedCurrency = forexMatch.first;
        _updatePriceField();
        return;
      }
    }

    final currencies = _tabController.index == 0
        ? _goldCurrencies
        : _forexCurrencies;
    if (currencies.isNotEmpty && _selectedCurrency == null) {
      // Default to gram_altin if available
      _selectedCurrency = currencies.firstWhere(
        (c) => c.code.toLowerCase() == 'gram_altin',
        orElse: () => currencies.first,
      );
      _updatePriceField();
    }
  }

  void _onTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        final currencies = _tabController.index == 0
            ? _goldCurrencies
            : _forexCurrencies;
        _selectedCurrency = currencies.isNotEmpty ? currencies.first : null;
        _updatePriceField();
      });
    }
  }

  void _updatePriceField() {
    if (_selectedCurrency != null) {
      final price = _isBuy
          ? _selectedCurrency!.selling
          : _selectedCurrency!.buying;
      _priceForDisplayController.text = _currencyFormat.format(price).trim();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountForDisplayController.dispose();
    _priceForDisplayController.dispose();
    _placeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AssetState>(assetProvider, (previous, next) {
      if (next is AssetError) {
        AppNotification.show(
          context,
          message: next.message,
          type: NotificationType.error,
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 20),
          ),
        ),
        title: const Text(
          'Yeni İşlem',
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionsScreen(),
                ),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history, size: 20, color: Colors.white),
            ),
          ),
          const Gap(16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Tabs
              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.gold,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gold.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.black,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                  unselectedLabelColor: Colors.white60,
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                  dividerColor: Colors.transparent,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  tabs: const [
                    Tab(text: 'Altın'),
                    Tab(text: 'Döviz'),
                  ],
                ),
              ),
              const Gap(24),

              // Custom Segmented Control for Buy/Sell
              _buildTypeSelector(),
              const Gap(24),

              // Currency Selection
              const Text(
                'Varlık Seçimi',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Gap(8),
              _buildCurrencySelector(),
              const Gap(20),

              // Amount & Price Inputs
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Miktar',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Gap(8),
                        _buildTextField(
                          _amountForDisplayController,
                          '0',
                          Icons.scale_rounded,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Birim Fiyat',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Gap(8),
                        _buildTextField(
                          _priceForDisplayController,
                          '0,00',
                          Icons.attach_money_rounded,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(20),

              // Date Selection
              const Text(
                'İşlem Tarihi',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Gap(8),
              _buildDatePicker(),
              const Gap(20),

              // Optional Fields
              _buildTextField(
                _placeController,
                'Alınan Yer / Platform (Opsiyonel)',
                Icons.store_mall_directory_outlined,
              ),
              const Gap(16),
              _buildTextField(
                _noteController,
                'İşlem Notu (Opsiyonel)',
                Icons.edit_note_rounded,
              ),
              const Gap(32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                    elevation: 8,
                    shadowColor: AppTheme.gold.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBackgroundColor: AppTheme.gold.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Kaydet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _isBuy = true);
                _updatePriceField();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 48,
                decoration: BoxDecoration(
                  color: _isBuy ? const Color(0xFF00C853) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Alım',
                    style: TextStyle(
                      color: _isBuy ? Colors.white : Colors.white54,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _isBuy = false);
                _updatePriceField();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 48,
                decoration: BoxDecoration(
                  color: !_isBuy ? const Color(0xFFFF5252) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Satım',
                    style: TextStyle(
                      color: !_isBuy ? Colors.white : Colors.white54,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return GestureDetector(
      onTap: _showCurrencyPicker,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _tabController.index == 0
                    ? Icons.workspace_premium
                    : Icons.currency_exchange,
                size: 20,
                color: AppTheme.gold,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Varlık',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    _selectedCurrency?.name ?? 'Seçiniz',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker() {
    final currencies = _tabController.index == 0
        ? _goldCurrencies
        : _forexCurrencies;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const Gap(16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(24),
              const Text(
                'Varlık Seçin',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              const Gap(24),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: currencies.length,
                  separatorBuilder: (_, __) => const Gap(12),
                  itemBuilder: (context, index) {
                    final currency = currencies[index];
                    final isSelected = currency.id == _selectedCurrency?.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCurrency = currency;
                          _updatePriceField();
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.gold.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.gold.withValues(alpha: 0.5)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              currency.name,
                              style: TextStyle(
                                color: isSelected
                                    ? AppTheme.gold
                                    : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(Icons.check, color: AppTheme.gold),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          prefixIcon: Icon(
            icon,
            size: 20,
            color: AppTheme.gold.withOpacity(0.7),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          locale: const Locale('tr', 'TR'),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppTheme.gold, // Header background & selection
                  onPrimary: Colors.black, // Header text & selection text
                  surface: Color(0xFF1E1E1E), // Background
                  onSurface: Colors.white, // Body text
                ),
                dialogBackgroundColor: const Color(0xFF1E1E1E),
                datePickerTheme: DatePickerThemeData(
                  headerBackgroundColor: const Color(0xFF1E1E1E),
                  headerForegroundColor: AppTheme.gold,
                  backgroundColor: const Color(0xFF1E1E1E),
                  surfaceTintColor: Colors.transparent,
                  dividerColor: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  headerHeadlineStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.gold,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: AppTheme.gold.withValues(alpha: 0.7),
            ),
            const Gap(12),
            Text(
              DateFormat('d MMMM yyyy', 'tr_TR').format(_selectedDate),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_selectedCurrency == null) {
      AppNotification.show(
        context,
        message: 'Lütfen bir para birimi/altın seçin',
        type: NotificationType.error,
      );
      return;
    }

    final amountText = _amountForDisplayController.text.trim();
    final priceText = _priceForDisplayController.text.trim();

    if (amountText.isEmpty) {
      AppNotification.show(
        context,
        message: 'Lütfen miktar girin',
        type: NotificationType.error,
      );
      return;
    }

    if (priceText.isEmpty) {
      AppNotification.show(
        context,
        message: 'Lütfen birim fiyat girin',
        type: NotificationType.error,
      );
      return;
    }

    try {
      final amount = _parseCurrency(amountText);
      final price = _parseCurrency(priceText);

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
          message: 'Birim fiyat 0\'dan büyük olmalıdır',
          type: NotificationType.error,
        );
        return;
      }

      setState(() => _isLoading = true);

      final success = await ref
          .read(assetProvider.notifier)
          .addAsset(
            currencyId: _selectedCurrency!.id,
            amount: amount,
            price: price,
            date: _selectedDate,
            isBuy: _isBuy,
            place: _placeController.text.trim(),
            note: _noteController.text.trim(),
          );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.pop(context);
          AppNotification.show(
            context,
            message: 'İşlem başarıyla kaydedildi',
            type: NotificationType.success,
          );
        }
      }
    } catch (e) {
      AppNotification.show(
        context,
        message: 'Geçersiz sayı formatı',
        type: NotificationType.error,
      );
    }
  }

  double _parseCurrency(String text) {
    // Remove all dots (thousands separators in TR)
    // Replace comma with dot (decimal separator in TR)
    final cleaned = text.replaceAll('.', '').replaceAll(',', '.');
    return double.parse(cleaned);
  }
}
