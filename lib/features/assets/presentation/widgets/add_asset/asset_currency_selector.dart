import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
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
    return InkWell(
      onTap: () => _showCurrencyPicker(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedCurrency?.name ?? 'Varlık Seçin',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(2),
                  Text(
                    selectedCurrency != null
                        ? 'Canlı Satış: ₺${NumberFormat('#,##0.00', 'tr_TR').format(selectedCurrency!.selling)} | Alış: ₺${NumberFormat('#,##0.00', 'tr_TR').format(selectedCurrency!.buying)}'
                        : 'Lütfen bir varlık seçin',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_down_1,
              color: Colors.white.withValues(alpha: 0.4),
              size: 18,
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
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          const Gap(24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: 'Varlık Ara...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.15),
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Iconsax.search_normal,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 18,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
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
                        fontSize: 14,
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
                                ? AppTheme.gold.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.gold.withValues(alpha: 0.2)
                                  : Colors.white.withValues(alpha: 0.05),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  currency.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppTheme.gold
                                        : Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Iconsax.tick_circle,
                                  color: AppTheme.gold,
                                  size: 20,
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
