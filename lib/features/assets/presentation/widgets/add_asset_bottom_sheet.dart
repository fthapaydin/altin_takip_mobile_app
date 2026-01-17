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

class AddAssetBottomSheet extends ConsumerStatefulWidget {
  const AddAssetBottomSheet({super.key});

  @override
  ConsumerState<AddAssetBottomSheet> createState() =>
      _AddAssetBottomSheetState();
}

class _AddAssetBottomSheetState extends ConsumerState<AddAssetBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Currency? _selectedCurrency;
  bool _isBuy = true;
  bool _isLoading = false;
  final _amountController = TextEditingController();
  final _priceController = TextEditingController();
  final _placeController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  List<Currency> _goldCurrencies = [];
  List<Currency> _forexCurrencies = [];

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
      _priceController.text =
          (_isBuy ? _selectedCurrency!.selling : _selectedCurrency!.buying)
              .toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _priceController.dispose();
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

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          color: AppTheme.background.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 40,
              spreadRadius: 0,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Gap(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Yeni İşlem',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 28,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
              const Gap(24),

              // Category Tabs with Glass Capsule Style
              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.gold,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gold.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.black,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  unselectedLabelColor: Colors.white60,
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
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

              // Buy/Sell Toggles
              Row(
                children: [
                  _buildTypeButton('Alım', true),
                  const Gap(16),
                  _buildTypeButton('Satım', false),
                ],
              ),
              const Gap(24),

              // Currency Selection
              const Text(
                'Varlık Seçimi',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(8),
              _buildDropdown(),
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
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Gap(8),
                        _buildTextField(
                          _amountController,
                          '0.00',
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
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Gap(8),
                        _buildTextField(
                          _priceController,
                          '0.00',
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
                  fontWeight: FontWeight.w500,
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
                    shadowColor: AppTheme.gold.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBackgroundColor: AppTheme.gold.withOpacity(0.5),
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
                      : const Text('Kaydet', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, bool isBuy) {
    final active = _isBuy == isBuy;
    final activeColor = isBuy
        ? const Color(0xFF00C853)
        : const Color(0xFFFF5252);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _isBuy = isBuy);
          _updatePriceField();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active ? activeColor.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? activeColor : Colors.white.withOpacity(0.1),
              width: active ? 1.5 : 1,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isBuy
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                size: 18,
                color: active ? activeColor : Colors.white54,
              ),
              const Gap(8),
              Text(
                label,
                style: TextStyle(
                  color: active ? activeColor : Colors.white54,
                  fontWeight: active ? FontWeight.bold : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    final currencies = _tabController.index == 0
        ? _goldCurrencies
        : _forexCurrencies;

    if (currencies.isEmpty) {
      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        alignment: Alignment.centerLeft,
        child: const Text(
          'Yükleniyor...',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Currency>(
          value: _selectedCurrency,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppTheme.gold,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter', // Assuming Inter or system font
          ),
          items: currencies.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _tabController.index == 0
                          ? Icons.monetization_on_outlined
                          : Icons.currency_exchange,
                      size: 16,
                      color: AppTheme.gold,
                    ),
                  ),
                  const Gap(12),
                  Text(c.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() => _selectedCurrency = val);
            _updatePriceField();
          },
        ),
      ),
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
          fontWeight: FontWeight.w600,
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
                  headerHelpStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  dayStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  yearStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  weekdayStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                  ),
                  // Explicitly handle text colors for different states
                  dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.black; // Black text on Gold background
                    }
                    if (states.contains(WidgetState.disabled)) {
                      return Colors.white38;
                    }
                    return Colors.white; // Default white text
                  }),
                  todayBorder: const BorderSide(color: AppTheme.gold),
                  todayForegroundColor: WidgetStateProperty.resolveWith((
                    states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.black; // Black if today is selected
                    }
                    return AppTheme.gold; // Gold if today is NOT selected
                  }),
                  confirmButtonStyle: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all(AppTheme.gold),
                    textStyle: WidgetStateProperty.all(
                      const TextStyle(
                        fontSize: 14, // Default size
                        fontWeight: FontWeight.w500, // Reduced from bold
                      ),
                    ),
                  ),
                  cancelButtonStyle: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all(Colors.white54),
                    textStyle: WidgetStateProperty.all(
                      const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500, // Reduced from w600
                      ),
                    ),
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
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: AppTheme.gold.withOpacity(0.7),
            ),
            const Gap(12),
            Text(
              DateFormat('d MMMM yyyy', 'tr_TR').format(_selectedDate),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.3)),
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

    final amountText = _amountController.text.trim();
    final priceText = _priceController.text.trim();

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
  }
}
