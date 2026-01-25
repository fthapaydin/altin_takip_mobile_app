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
            leading: const BackButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
              centerTitle: false,
              title: const Text(
                'Geçmiş İşlemler',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.gold.withValues(alpha: 0.05),
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
      return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
    }

    if (state is AssetLoaded) {
      if (state.assets.isEmpty) {
        return const Center(
          child: Text(
            'Henüz işlem bulunmuyor',
            style: TextStyle(color: Colors.white54),
          ),
        );
      }

      // Sort by date descending
      final sortedAssets = List<Asset>.from(state.assets)
        ..sort((a, b) => b.date.compareTo(a.date));

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: sortedAssets.length,
        itemBuilder: (context, index) {
          final asset = sortedAssets[index];
          return _buildTransactionItem(context, ref, asset, isLast: index == sortedAssets.length - 1);
        },
      );
    }
    
    if (state is AssetError) {
      return Center(
        child: Text(
          state.message,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildTransactionItem(BuildContext context, WidgetRef ref, Asset asset, {bool isLast = false}) {
    final isBuy = asset.type == 'buy';
    final useDynamicDate = ref.watch(preferenceProvider).useDynamicDate;
    final formattedDate = DateFormatter.format(
      asset.date,
      useDynamic: useDynamicDate,
    );

    double? profit;
    if (isBuy && asset.currency != null) {
      final currentPrice = asset.currency!.buying;
      final costPrice = asset.price;
      profit = (currentPrice - costPrice) * asset.amount;
    }

    final isProfitPositive = profit != null && profit >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isBuy ? Colors.green : Colors.red).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isBuy ? Icons.arrow_downward : Icons.arrow_upward,
                color: isBuy ? Colors.green : Colors.red,
                size: 20,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.currency?.name ?? 'Varlık',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${NumberFormat('#,##0.##', 'tr_TR').format(asset.amount)} adet',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '₺${NumberFormat('#,##0.00', 'tr_TR').format(asset.price)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                 if (profit != null) ...[
                      const Gap(4),
                      Text(
                        '${isProfitPositive ? '+' : ''}₺${NumberFormat('#,##0.00', 'tr_TR').format(profit)}',
                        style: TextStyle(
                          color: isProfitPositive ? Colors.green : Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
