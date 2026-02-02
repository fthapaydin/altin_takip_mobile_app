import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/widgets/currency_icon.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';

class AssetCurrencySelector extends StatelessWidget {
  final Currency? selectedCurrency;
  final List<Currency> currencies;
  final bool isGold;
  final ValueChanged<Currency> onCurrencyChanged;

  const AssetCurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.currencies,
    required this.isGold,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCurrencyPicker(context),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.gold.withOpacity(0.2),
                    AppTheme.gold.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
              ),
              child: CurrencyIcon(
                iconUrl: selectedCurrency?.iconUrl,
                isGold: isGold,
                size: 40,
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
                    selectedCurrency?.name ?? 'Seçiniz',
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
              Iconsax.arrow_down_1,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _AssetSelectionSheet(
          currencies: currencies,
          selectedCurrency: selectedCurrency,
          onCurrencySelected: onCurrencyChanged,
          isGold: isGold,
        );
      },
    );
  }
}

class _AssetSelectionSheet extends StatefulWidget {
  final List<Currency> currencies;
  final Currency? selectedCurrency;
  final ValueChanged<Currency> onCurrencySelected;
  final bool isGold;

  const _AssetSelectionSheet({
    required this.currencies,
    required this.selectedCurrency,
    required this.onCurrencySelected,
    required this.isGold,
  });

  @override
  State<_AssetSelectionSheet> createState() => _AssetSelectionSheetState();
}

class _AssetSelectionSheetState extends State<_AssetSelectionSheet> {
  late List<Currency> _filteredCurrencies;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = widget.currencies;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCurrencies = widget.currencies.where((c) {
        return c.name.toLowerCase().contains(query) ||
            c.code.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // Taller for search
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
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Varlık Ara...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Iconsax.search_normal,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const Gap(16),
          Expanded(
            child: _filteredCurrencies.isEmpty
                ? Center(
                    child: Text(
                      'Sonuç bulunamadı',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: _filteredCurrencies.length,
                    separatorBuilder: (_, __) => const Gap(12),
                    itemBuilder: (context, index) {
                      final currency = _filteredCurrencies[index];
                      final isSelected =
                          currency.id == widget.selectedCurrency?.id;
                      return GestureDetector(
                        onTap: () {
                          widget.onCurrencySelected(currency);
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
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.gold.withOpacity(0.2),
                                      AppTheme.gold.withOpacity(0.05),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.gold.withOpacity(0.2),
                                  ),
                                ),
                                child: CurrencyIcon(
                                  iconUrl: currency.iconUrl,
                                  isGold: currency.isGold,
                                  size: 40,
                                  color: AppTheme.gold,
                                ),
                              ),
                              const Gap(12),
                              Expanded(
                                child: Text(
                                  currency.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppTheme.gold
                                        : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Iconsax.tick_circle,
                                  color: AppTheme.gold,
                                ),
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
  }
}
