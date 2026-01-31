import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/utils/date_formatter.dart';
import 'package:altin_takip/features/assets/presentation/asset_notifier.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:altin_takip/features/settings/presentation/preference_notifier.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:altin_takip/features/assets/presentation/add_asset_screen.dart';
import 'package:altin_takip/core/widgets/currency_icon.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assetProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: AppTheme.background,
            expandedHeight: 120,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                onPressed: () => _showAddAssetScreen(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: AppTheme.gold, size: 20),
                ),
              ),
              const Gap(16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
              centerTitle: false,
              title: const Text(
                'Geçmiş İşlemler',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.gold.withValues(alpha: 0.1),
                      AppTheme.background,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        body: _buildBody(context, ref, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, AssetState state) {
    if (state is AssetLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.gold),
      );
    }

    if (state is AssetLoaded) {
      if (state.assets.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              const Gap(16),
              Text(
                'Henüz işlem bulunmuyor',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              ),
            ],
          ).animate().fadeIn().scale(),
        );
      }

      // Sort by date descending
      final sortedAssets = List<Asset>.from(state.assets)
        ..sort((a, b) => b.date.compareTo(a.date));

      // Group by date
      final groupedAssets = <String, List<Asset>>{};
      for (var asset in sortedAssets) {
        final dateKey = DateFormat('yyyy-MM-dd').format(asset.date);
        if (!groupedAssets.containsKey(dateKey)) {
          groupedAssets[dateKey] = [];
        }
        groupedAssets[dateKey]!.add(asset);
      }

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 80, top: 20),
        itemCount: groupedAssets.keys.length,
        itemBuilder: (context, index) {
          final dateKey = groupedAssets.keys.elementAt(index);
          final assets = groupedAssets[dateKey]!;
          return _buildDateGroup(context, ref, dateKey, assets, index);
        },
      );
    }

    if (state is AssetError) {
      return Center(
        child: Text(state.message, style: const TextStyle(color: Colors.red)),
      );
    }

    return const SizedBox();
  }

  Widget _buildDateGroup(
    BuildContext context,
    WidgetRef ref,
    String dateKey,
    List<Asset> assets,
    int groupIndex,
  ) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final isYesterday =
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1;

    String headerText;
    if (isToday) {
      headerText = 'Bugün';
    } else if (isYesterday) {
      headerText = 'Dün';
    } else {
      headerText = DateFormat('d MMMM yyyy', 'tr_TR').format(date);
    }

    return StickyHeader(
      header: Container(
        width: double.infinity,
        color: AppTheme.background, // Match items background for readability
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Text(
              headerText,
              style: TextStyle(
                color: AppTheme.gold,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const Gap(8),
            Expanded(
              child: Divider(
                color: AppTheme.gold.withValues(alpha: 0.2),
                height: 1,
              ),
            ),
          ],
        ),
      ),
      content: Column(
        children: assets.asMap().entries.map((entry) {
          final index = entry.key;
          final asset = entry.value;
          return _buildTransactionItem(
            context,
            ref,
            asset,
            index: index + (groupIndex * 10),
          ); // Offset index for staggering
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    WidgetRef ref,
    Asset asset, {
    required int index,
  }) {
    final isBuy = asset.type == 'buy';
    final useDynamicDate = ref.watch(preferenceProvider).useDynamicDate;
    final formattedDate = DateFormatter.format(
      asset.date,
      useDynamic: useDynamicDate,
    );
    final timeStr = DateFormat('HH:mm').format(asset.date);

    double? profit;
    if (isBuy && asset.currency != null) {
      final currentPrice = asset.currency!.buying;
      final costPrice = asset.price;
      profit = (currentPrice - costPrice) * asset.amount;
    }

    final isProfitPositive = profit != null && profit >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {}, // Optional details tap
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Container
                Container(
                  width: 44,
                  height: 44,
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
                    iconUrl: asset.currency?.iconUrl,
                    isGold: asset.currency?.isGold ?? false,
                    size: 44,
                    color: AppTheme.gold,
                  ),
                ),
                const Gap(16),

                // Asset Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.currency?.name ?? 'Varlık',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      const Gap(4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          const Gap(4),
                          Text(
                            useDynamicDate ? formattedDate : timeStr,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Values
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isBuy ? '+' : '-'}${NumberFormat('#,##0.##', 'tr_TR').format(asset.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isBuy ? Colors.green : Colors.red,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      '₺${NumberFormat('#,##0.00', 'tr_TR').format(asset.price)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                    if (profit != null) ...[
                      const Gap(4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (isProfitPositive ? Colors.green : Colors.red)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isProfitPositive
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              size: 10,
                              color: isProfitPositive
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const Gap(2),
                            Text(
                              '₺${NumberFormat('#,##0.0', 'tr_TR').format(profit.abs())}',
                              style: TextStyle(
                                color: isProfitPositive
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1, curve: Curves.easeOut);
  }

  void _showAddAssetScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAssetScreen()),
    );
  }
}
