import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';
import 'package:altin_takip/features/settings/presentation/preference_notifier.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/currency_list_card.dart';

class DashboardAssetsTab extends ConsumerStatefulWidget {
  final AssetState state;
  final String type; // 'Altın' or 'Forex'
  final Function(Currency, bool) onNavigateToHistory;
  final Function(List<String>) onReorder;
  final List<String> currentOrder;

  const DashboardAssetsTab({
    super.key,
    required this.state,
    required this.type,
    required this.onNavigateToHistory,
    required this.onReorder,
    required this.currentOrder,
  });

  @override
  ConsumerState<DashboardAssetsTab> createState() => _DashboardAssetsTabState();
}

class _DashboardAssetsTabState extends ConsumerState<DashboardAssetsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state is AssetLoading) {
      return const _AssetTabShimmer();
    }

    if (widget.state is AssetLoaded) {
      final isGoldTab = widget.type == 'Altın';
      final loadedState = widget.state as AssetLoaded;

      final filteredCurrencies = loadedState.currencies.where((c) {
        if (isGoldTab) return c.isGold;
        return !c.isGold;
      }).toList();

      final sortedCurrencies = _getSortedCurrencies(
        filteredCurrencies,
        widget.currentOrder,
      );

      final displayCurrencies = _searchQuery.isEmpty
          ? sortedCurrencies
          : sortedCurrencies.where((c) {
              final query = _searchQuery.toLowerCase();
              final name = c.name.toLowerCase();
              final code = c.code.toLowerCase();
              return name.contains(query) || code.contains(query);
            }).toList();

      return Column(
        children: [
          _buildSearchBar(isGoldTab),
          Expanded(
            child: _searchQuery.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                    itemCount: displayCurrencies.length,
                    itemBuilder: (context, index) => _buildCardItem(displayCurrencies[index]),
                  )
                : ReorderableListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                    itemCount: displayCurrencies.length,
                    proxyDecorator: (child, index, animation) => Material(
                      color: Colors.transparent,
                      elevation: 4,
                      borderRadius: BorderRadius.circular(20),
                      child: child,
                    ),
                    onReorder: (oldIndex, newIndex) => _handleReorder(displayCurrencies, oldIndex, newIndex),
                    itemBuilder: (context, index) => Container(
                      key: ValueKey(displayCurrencies[index].code),
                      child: _buildCardItem(displayCurrencies[index]),
                    ),
                  ),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildSearchBar(bool isGoldTab) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AppTheme.surface,
          hintText: '${isGoldTab ? 'Altın' : 'Döviz'} Ara...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
          prefixIcon: Icon(Iconsax.search_normal_1, size: 18, color: Colors.white.withOpacity(0.3)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.04)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.04)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppTheme.gold, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, size: 18, color: Colors.white.withOpacity(0.3)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildCardItem(Currency currency) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CurrencyListCard(
        currency: currency,
        isGold: widget.type == 'Altın',
        useDynamicDate: ref.watch(preferenceProvider).useDynamicDate,
        onTap: () => widget.onNavigateToHistory(currency, widget.type == 'Altın'),
      ),
    );
  }

  void _handleReorder(List<Currency> displayCurrencies, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = displayCurrencies.removeAt(oldIndex);
    displayCurrencies.insert(newIndex, item);

    final newOrder = displayCurrencies.map((c) => c.code).toList();
    widget.onReorder(newOrder);
  }

  List<Currency> _getSortedCurrencies(List<Currency> currencies, List<String> order) {
    if (order.isEmpty) return currencies;

    final sorted = List<Currency>.from(currencies);
    sorted.sort((a, b) {
      final indexA = order.indexOf(a.code);
      final indexB = order.indexOf(b.code);

      if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);
      if (indexA != -1) return -1;
      if (indexB != -1) return 1;
      return 0;
    });

    return sorted;
  }
}

class _AssetTabShimmer extends StatelessWidget {
  const _AssetTabShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      itemCount: 8,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Shimmer.fromColors(
          baseColor: AppTheme.surface,
          highlightColor: Colors.white.withOpacity(0.05),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
          ),
        ),
      ),
    );
  }
}
