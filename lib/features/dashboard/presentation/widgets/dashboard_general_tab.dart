import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';
import 'package:altin_takip/features/settings/presentation/preference_notifier.dart';
import 'package:altin_takip/features/dashboard/presentation/transactions_screen.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/market_summary_widget.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/recent_transactions_widget.dart';
import 'package:iconsax/iconsax.dart';

class DashboardGeneralTab extends ConsumerWidget {
  final AssetState state;
  final Function(Currency, bool) onNavigateToHistory;
  final VoidCallback onShowAddAsset;

  const DashboardGeneralTab({
    super.key,
    required this.state,
    required this.onNavigateToHistory,
    required this.onShowAddAsset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverGap(24),
        SliverToBoxAdapter(child: _buildSectionTitle(context, 'Günün Özeti')),
        const SliverGap(16),
        _buildMarketSection(),
        const SliverGap(40),
        SliverToBoxAdapter(
          child: _buildSectionTitle(
            context,
            'Son İşlemler',
            onMoreTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionsScreen(),
                ),
              );
            },
          ),
        ),
        const SliverGap(16),
        _buildTransactionsSection(ref),
        const SliverGap(100),
      ],
    );
  }

  Widget _buildMarketSection() {
    if (state is AssetLoading) {
      return SliverToBoxAdapter(child: _buildGridShimmer());
    } else if (state is AssetLoaded) {
      return SliverToBoxAdapter(
        child: MarketSummaryWidget(
          currencies: _getPersonalizedCurrencies(state as AssetLoaded),
          onNavigateToHistory: onNavigateToHistory,
        ),
      );
    }
    return const SliverToBoxAdapter(child: SizedBox());
  }

  Widget _buildTransactionsSection(WidgetRef ref) {
    if (state is AssetLoading) {
      return SliverToBoxAdapter(child: _buildTransactionsShimmer());
    } else if (state is AssetLoaded) {
      final loadedState = state as AssetLoaded;
      final displayAssets = loadedState.dashboardData?.recentTransactions.take(5).toList() ??
          (List<Asset>.from(loadedState.assets)
            ..sort((a, b) => b.date.compareTo(a.date))).take(5).toList();

      return SliverToBoxAdapter(
        child: RecentTransactionsWidget(
          assets: displayAssets,
          onNavigateToHistory: onNavigateToHistory,
          onShowAddAsset: onShowAddAsset,
          useDynamicDate: ref.watch(preferenceProvider).useDynamicDate,
        ),
      );
    }
    return const SliverToBoxAdapter(child: SizedBox());
  }

  List<Currency> _getPersonalizedCurrencies(AssetLoaded state) {
    if (state.assets.isEmpty) {
      return state.currencies.where((c) {
        final code = c.code.toLowerCase();
        return code == 'gram_altin' ||
            code == 'ceyrek_altin' ||
            code == 'usd' ||
            code == 'eur';
      }).toList();
    }

    final userAssets = List<Asset>.from(state.assets);
    userAssets.sort((a, b) => b.date.compareTo(a.date));

    final Set<int> uniqueCurrencyIds = {};
    for (var asset in userAssets) {
      uniqueCurrencyIds.add(asset.currencyId);
      if (uniqueCurrencyIds.length >= 4) break;
    }

    final personalizedList = <Currency>[];
    for (var id in uniqueCurrencyIds) {
      try {
        final currency = state.currencies.firstWhere((c) => c.id == id);
        personalizedList.add(currency);
      } catch (_) {}
    }

    if (personalizedList.isEmpty) {
      return state.currencies.where((c) {
        final code = c.code.toLowerCase();
        return code == 'gram_altin' ||
            code == 'ceyrek_altin' ||
            code == 'usd' ||
            code == 'eur';
      }).toList();
    }

    return personalizedList;
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    double padding = 24,
    VoidCallback? onMoreTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w400,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          if (onMoreTap != null)
            TextButton(
              onPressed: onMoreTap,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.gold,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                children: [
                  Text(
                    'Tümünü Gör',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                  Gap(4),
                  Icon(Iconsax.arrow_right_1, size: 14),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGridShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: AppTheme.glassColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.white.withOpacity(0.05),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                      const Gap(8),
                      Container(width: 50, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                  Container(width: 80, height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 50, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3))),
                      Container(width: 40, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: List.generate(3, (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.03)),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.03),
              highlightColor: Colors.white.withOpacity(0.06),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 80, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                          const Gap(6),
                          Container(width: 120, height: 8, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 50, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                        const Gap(6),
                        Container(width: 60, height: 8, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )),
      ),
    );
  }
}
