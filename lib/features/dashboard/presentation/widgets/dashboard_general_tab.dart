import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/utils/date_formatter.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';
import 'package:altin_takip/features/settings/presentation/preference_notifier.dart';
import 'package:altin_takip/features/dashboard/presentation/transactions_screen.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/transaction_list_item.dart';

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
        if (state is AssetLoading)
          SliverToBoxAdapter(child: _buildCarouselShimmer())
        else if (state is AssetLoaded)
          SliverToBoxAdapter(
            child: _buildCurrencyCarousel(
              context,
              ref,
              _getPersonalizedCurrencies(state as AssetLoaded),
            ),
          ),
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
        _buildTransactionList(context, state),
        const SliverGap(100),
      ],
    );
  }

  List<Currency> _getPersonalizedCurrencies(AssetLoaded state) {
    // If user has no assets, return default list
    if (state.assets.isEmpty) {
      return state.currencies.where((c) {
        final code = c.code.toLowerCase();
        return code == 'gram_altin' ||
            code == 'ceyrek_altin' ||
            code == 'usd' ||
            code == 'eur';
      }).toList();
    }

    // Get unique currency IDs from user assets, sorted by date (most recent first)
    final userAssets = List<Asset>.from(state.assets);
    userAssets.sort((a, b) => b.date.compareTo(a.date));

    final Set<int> uniqueCurrencyIds = {};
    for (var asset in userAssets) {
      uniqueCurrencyIds.add(asset.currencyId);
      if (uniqueCurrencyIds.length >= 3) break; // Limit to 3 most recent
    }

    // Find these currencies in the loaded currencies list
    final personalizedList = <Currency>[];
    for (var id in uniqueCurrencyIds) {
      try {
        final currency = state.currencies.firstWhere((c) => c.id == id);
        personalizedList.add(currency);
      } catch (_) {
        // Currency not found
      }
    }

    // If for some reason we found nothing (e.g. ID mismatch), fallback to defaults
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
              fontWeight: FontWeight.bold,
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
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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

  Widget _buildCarouselShimmer() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        separatorBuilder: (_, __) => const Gap(12),
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: AppTheme.surface,
          highlightColor: Colors.white10,
          child: Container(
            width: 150,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyCarousel(
    BuildContext context,
    WidgetRef ref,
    List<Currency> currencies,
  ) {
    if (currencies.isEmpty) {
      return Container(
        height: 100,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppTheme.glassColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.chart_2,
                    color: AppTheme.gold,
                    size: 24,
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms, color: Colors.white24),
            const Gap(16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Piyasalar Takipte',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Veriler güncelleniyor...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: currencies.length,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        separatorBuilder: (_, __) => const Gap(12),
        itemBuilder: (context, index) {
          final currency = currencies[index];
          final useDynamicDate = ref.watch(preferenceProvider).useDynamicDate;

          return GestureDetector(
            onTap: () => onNavigateToHistory(currency, currency.isGold),
            child: Container(
              width: 140,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.glassColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          currency.isGold ? currency.name : currency.code,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        DateFormatter.format(
                          currency.lastUpdatedAt,
                          useDynamic: useDynamicDate,
                        ),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '₺${NumberFormat('#,##0.00', 'tr_TR').format(currency.selling)}',
                    style: const TextStyle(
                      fontFeatures: [FontFeature.tabularFigures()],
                      color: AppTheme.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, AssetState state) {
    if (state is AssetLoading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Shimmer.fromColors(
              baseColor: AppTheme.surface,
              highlightColor: Colors.white10,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          childCount: 5,
        ),
      );
    }

    if (state is AssetLoaded) {
      if (state.assets.isEmpty) {
        return SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.surface, AppTheme.surface.withOpacity(0.5)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.wallet_money,
                    color: AppTheme.gold,
                    size: 32,
                  ),
                ).animate().scale(delay: 200.ms, duration: 400.ms),
                const Gap(16),
                const Text(
                  'Yatırım Yolculuğuna Başla',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Gap(8),
                Text(
                  'Henüz bir işlem yapmadınız. İlk varlığınızı ekleyerek portföyünüzü oluşturun.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const Gap(24),
                ElevatedButton(
                  onPressed: onShowAddAsset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Varlık Ekle',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Use recent transactions from dashboard API if available
      final displayAssets =
          state.dashboardData?.recentTransactions.take(5).toList() ??
          (List<Asset>.from(
            state.assets,
          )..sort((a, b) => b.date.compareTo(a.date))).take(5).toList();

      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final asset = displayAssets[index];
          return TransactionListItem(
            asset: asset,
            onTap: () {
              if (asset.currency != null) {
                onNavigateToHistory(asset.currency!, asset.currency!.isGold);
              }
            },
          );
        }, childCount: displayAssets.length),
      );
    }
    return const SliverToBoxAdapter(child: SizedBox());
  }
}
