import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/assets/presentation/asset_notifier.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/features/dashboard/presentation/transactions_screen.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/features/assets/presentation/widgets/add_asset/transaction_type_selector.dart';
import 'package:altin_takip/features/assets/presentation/widgets/add_asset/asset_currency_selector.dart';
import 'package:altin_takip/features/assets/presentation/widgets/add_asset/custom_asset_text_field.dart';
import 'package:altin_takip/features/assets/presentation/widgets/add_asset/asset_date_picker.dart';

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
              child: const Icon(
                Iconsax.receipt_1,
                size: 20,
                color: Colors.white,
              ),
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

              // Transaction Type Selector
              TransactionTypeSelector(
                isBuy: _isBuy,
                onTypeChanged: (value) {
                  setState(() => _isBuy = value);
                  _updatePriceField();
                },
              ),
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
              AssetCurrencySelector(
                selectedCurrency: _selectedCurrency,
                currencies: _tabController.index == 0
                    ? _goldCurrencies
                    : _forexCurrencies,
                isGold: _tabController.index == 0,
                onCurrencyChanged: (currency) {
                  setState(() {
                    _selectedCurrency = currency;
                    _updatePriceField();
                  });
                },
              ),
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
                        CustomAssetTextField(
                          controller: _amountForDisplayController,
                          hint: '0',
                          icon: Iconsax.weight,
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
                        CustomAssetTextField(
                          controller: _priceForDisplayController,
                          hint: '0,00',
                          icon: Iconsax.money,
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
              AssetDatePicker(
                selectedDate: _selectedDate,
                onDateChanged: (date) => setState(() => _selectedDate = date),
              ),
              const Gap(20),

              // Optional Fields
              CustomAssetTextField(
                controller: _placeController,
                hint: 'Alınan Yer / Platform (Opsiyonel)',
                icon: Iconsax.shop,
              ),
              const Gap(16),
              CustomAssetTextField(
                controller: _noteController,
                hint: 'İşlem Notu (Opsiyonel)',
                icon: Iconsax.note,
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
            isBuy: _isBuy,
            date: _selectedDate,
            place: _placeController.text.trim(),
            note: _noteController.text.trim(),
          );

      if (success) {
        if (mounted) {
          Navigator.pop(context);
          AppNotification.show(
            context,
            message: 'İşlem başarıyla kaydedildi',
            type: NotificationType.success,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppNotification.show(
          context,
          message: 'Bir hata oluştu: ${e.toString()}',
          type: NotificationType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _parseCurrency(String value) {
    if (value.isEmpty) return 0.0;
    // Replace comma with dot for parsing if using TR locale format
    String normalized = value.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0.0;
  }
}
