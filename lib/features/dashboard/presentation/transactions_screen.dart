import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/assets/presentation/asset_notifier.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:altin_takip/features/assets/presentation/add_asset_screen.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/widgets/app_bar_widget.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assetProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBarWidget(
        title: 'Geçmiş İşlemler',
        showBack: true,
        centerTitle: true,
        isLargeTitle: false,
        actions: [
          AppBarActionButton(
            icon: Iconsax.add,
            onTap: () => _showAddAssetScreen(context),
          ),
          const Gap(16),
        ],
      ),
      body: _buildBody(context, ref, state),
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
                  Iconsax.receipt_1,
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
        padding: EdgeInsets.only(
          bottom: 80,
          top:
              MediaQuery.of(context).padding.top +
              AppBarWidget.getExpandedHeight(isLargeTitle: false) +
              12.0,
        ),
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
        color: AppTheme.background,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Text(
              headerText,
              style: const TextStyle(
                color: AppTheme.gold,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
              ),
            ),
            const Gap(8),
            Expanded(
              child: Divider(color: AppTheme.gold.withOpacity(0.12), height: 1),
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
          );
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
    final formatter = NumberFormat('#,##0.00', 'tr_TR');

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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isBuy
              ? [const Color(0xFF131715), const Color(0xFF0E1110)]
              : [const Color(0xFF181414), const Color(0xFF120E0E)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBuy
              ? const Color(0xFF4ADE80).withOpacity(0.06)
              : const Color(0xFFF87171).withOpacity(0.06),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(
              children: [
                // ── Sleek Vertical Accent Indicator ──
                Container(
                  width: 3,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isBuy
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFFF87171),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Gap(12),

                // ── Main Content Area ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Row 1: Name and Quantity
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              asset.currency?.name ?? 'Varlık',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: Colors.white,
                                letterSpacing: 0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Gap(12),
                          Text(
                            '${isBuy ? '+' : '-'}${NumberFormat('#,##0.##', 'tr_TR').format(asset.amount)} Adet',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: isBuy
                                  ? const Color(0xFF4ADE80)
                                  : const Color(0xFFF87171),
                            ),
                          ),
                        ],
                      ),
                      const Gap(6),
                      // Row 2: Code/Time and Price + Profit
                      Row(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₺${formatter.format(asset.price)}',
                                style: TextStyle(
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              if (profit != null) ...[
                                const Gap(8),
                                _ProfitTag(
                                  profit: profit,
                                  isProfitPositive: isProfitPositive,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddAssetScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAssetScreen()),
    );
  }
}

class _ProfitTag extends StatelessWidget {
  final double profit;
  final bool isProfitPositive;

  const _ProfitTag({required this.profit, required this.isProfitPositive});

  @override
  Widget build(BuildContext context) {
    final color = isProfitPositive
        ? const Color(0xFF4ADE80)
        : const Color(0xFFF87171);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.12), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isProfitPositive ? Iconsax.trend_up : Iconsax.trend_down,
            size: 10,
            color: color,
          ),
          const Gap(2),
          Text(
            '₺${NumberFormat('#,##0.00', 'tr_TR').format(profit.abs())}',
            style: TextStyle(
              fontFeatures: const [FontFeature.tabularFigures()],
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
