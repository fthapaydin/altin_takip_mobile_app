import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/core/storage/storage_service.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:altin_takip/core/widgets/premium_error_view.dart';
import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:altin_takip/features/assets/presentation/asset_notifier.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/assets/presentation/widgets/add_asset_bottom_sheet.dart';
import 'package:altin_takip/core/utils/date_formatter.dart';
import 'package:altin_takip/features/settings/presentation/preference_notifier.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class AssetsScreen extends ConsumerStatefulWidget {
  const AssetsScreen({super.key});

  @override
  ConsumerState<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends ConsumerState<AssetsScreen> {
  final ScrollController _scrollController = ScrollController();
  final Set<String> _expandedGroups = {};
  List<String> _customOrder = [];
  bool _orderLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(assetProvider.notifier).loadAllAssets();
      await _loadSavedOrder();
    });
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadSavedOrder() async {
    final storageService = sl<StorageService>();
    final savedOrder = await storageService.getAssetOrder();
    if (savedOrder != null && mounted) {
      setState(() {
        _customOrder = savedOrder;
        _orderLoaded = true;
      });
    } else {
      setState(() => _orderLoaded = true);
    }
  }

  Future<void> _saveOrder() async {
    final storageService = sl<StorageService>();
    await storageService.saveAssetOrder(_customOrder);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(assetProvider.notifier).loadMoreAssets();
    }
  }

  void _showAddAssetBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddAssetBottomSheet(),
    );
  }

  Map<String, List<Asset>> _groupAssets(List<Asset> assets) {
    final grouped = <String, List<Asset>>{};
    for (final asset in assets) {
      final key = asset.currency?.code ?? 'unknown';
      grouped.putIfAbsent(key, () => []).add(asset);
    }
    return grouped;
  }

  List<MapEntry<String, List<Asset>>> _getSortedGroups(
    Map<String, List<Asset>> grouped,
  ) {
    if (_customOrder.isEmpty) {
      _customOrder = grouped.keys.toList();
    }

    for (final key in grouped.keys) {
      if (!_customOrder.contains(key)) {
        _customOrder.add(key);
      }
    }

    _customOrder.removeWhere((key) => !grouped.containsKey(key));

    final sorted = <MapEntry<String, List<Asset>>>[];
    for (final key in _customOrder) {
      if (grouped.containsKey(key)) {
        sorted.add(MapEntry(key, grouped[key]!));
      }
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assetProvider);

    ref.listen<AssetState>(assetProvider, (prev, next) {
      if (next is AssetError) {
        AppNotification.show(
          context,
          message: next.message,
          type: NotificationType.error,
        );
      } else if (next is AssetLoaded && next.actionError != null) {
        AppNotification.show(
          context,
          message: next.actionError!,
          type: NotificationType.error,
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: AppTheme.background,
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              centerTitle: false,
              title: const Text(
                'Portföyüm',
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
            actions: [
              IconButton(
                onPressed: _showAddAssetBottomSheet,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppTheme.gold,
                    size: 20,
                  ),
                ),
              ),
              const Gap(12),
            ],
          ),
        ],
        body: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(AssetState state) {
    if (state is AssetLoading || !_orderLoaded) {
      return _buildShimmerList();
    }

    if (state is AssetError) {
      return PremiumErrorView(
        message: state.message,
        onRetry: () =>
            ref.read(assetProvider.notifier).loadAllAssets(refresh: true),
      );
    }

    if (state is AssetLoaded) {
      if (state.assets.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, color: Colors.white24, size: 64),
              Gap(16),
              Text(
                'Henüz varlık eklemediniz',
                style: TextStyle(color: Colors.white38, fontSize: 16),
              ),
            ],
          ),
        );
      }

      final groupedAssets = _groupAssets(state.assets);
      final sortedGroups = _getSortedGroups(groupedAssets);

      return RefreshIndicator(
        onRefresh: () =>
            ref.read(assetProvider.notifier).loadAllAssets(refresh: true),
        color: AppTheme.gold,
        child: ReorderableListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          itemCount: sortedGroups.length,
          proxyDecorator: (child, index, animation) {
            return Material(
              color: Colors.transparent,
              elevation: 8,
              shadowColor: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              child: child,
            );
          },
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = _customOrder.removeAt(oldIndex);
              _customOrder.insert(newIndex, item);
            });
            _saveOrder();
          },
          itemBuilder: (context, index) {
            final entry = sortedGroups[index];
            return _buildAssetGroup(
              key: ValueKey(entry.key),
              currencyCode: entry.key,
              assets: entry.value,
            );
          },
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildAssetGroup({
    required Key key,
    required String currencyCode,
    required List<Asset> assets,
  }) {
    final isExpanded = _expandedGroups.contains(currencyCode);
    final currency = assets.first.currency;
    final isGold = currency?.isGold ?? false;
    final totalAmount = assets.fold<double>(
      0,
      (sum, a) => sum + (a.type == 'buy' ? a.amount : -a.amount),
    );
    final totalValue = assets.fold<double>(
      0,
      (sum, a) =>
          sum + (a.type == 'buy' ? a.amount * a.price : -a.amount * a.price),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isExpanded
            ? AppTheme.surface
            : AppTheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isExpanded
              ? AppTheme.gold.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.03),
        ),
        boxShadow: [
          if (isExpanded)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedGroups.remove(currencyCode);
                } else {
                  _expandedGroups.add(currencyCode);
                }
              });
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                   // Drag Handle (Simplified)
                  ReorderableDragStartListener(
                    index: _customOrder.indexOf(currencyCode),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.drag_handle_rounded,
                        color: Colors.white.withValues(alpha: 0.2),
                        size: 20,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          isGold ? const Color(0xFFFFD700) : Colors.blueGrey,
                          isGold ? const Color(0xFFB8860B) : Colors.black,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isGold ? AppTheme.gold : Colors.blueGrey)
                              .withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      isGold
                          ? Icons.workspace_premium
                          : Icons.currency_exchange,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGold
                              ? (currency?.name ?? currencyCode)
                              : currencyCode,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                         const Gap(4),
                        Row(
                          children: [
                            Container(
                               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                               decoration: BoxDecoration(
                                   color: Colors.white.withValues(alpha: 0.05),
                                   borderRadius: BorderRadius.circular(4)
                               ),
                               child: Text(
                                '${assets.length} işlem',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                       Text(
                        '${_formatAmount(totalAmount)} adet',
                        style: TextStyle(
                          color: isGold ? AppTheme.gold : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '₺${NumberFormat('#,##0.00', 'tr_TR').format(totalValue.abs())}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable transactions
           AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildGroupedTransactions(assets),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedTransactions(List<Asset> assets) {
    final buys = assets.where((a) => a.type == 'buy').toList();
    // Sell transactions are hidden from view but used for balance calculations elsewhere

    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            color: Colors.white.withValues(alpha: 0.05),
            height: 1,
            thickness: 1,
          ),
          const Gap(16),
          // Buys section
          if (buys.isNotEmpty) ...[
            // Optional: Header can be removed if we only show buys, 
            // but keeping it for clarity as "Alışlar" (Purchases/Holdings)
            _buildTransactionSectionHeader('Varlıklar', buys.length, Colors.green),
            const Gap(8),
            ...buys.map((asset) => _buildTransactionItem(asset, isLast: asset == buys.last)),
          ],
          
          if (buys.isEmpty)
             Padding(
               padding: const EdgeInsets.all(16),
               child: Text(
                 'Görüntülenecek aktif varlık bulunamadı.',
                 style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
               ),
             )
        ],
      ),
    );
  }

  Widget _buildTransactionSectionHeader(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const Gap(12),
          Text(
            '$title ($count)',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Asset asset, {bool isLast = false}) {
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

    return InkWell(
      onTap: () => _showAssetActionsSheet(asset),
      child: Stack(
        children: [
          // Connecting Line (Timeline)
          if (!isLast)
          Positioned(
            left: 23, // 20 pad + 3 center of dot
            top: 24,
            bottom: 0,
            width: 1,
            child: Container(
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 // Dot
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isBuy ? Colors.green : Colors.red,
                      width: 1.5,
                    ),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBuy ? 'Alış İşlemi' : 'Satış İşlemi',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const Gap(2),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                        ),
                      ),
                       // Profit Badge (Inline)
                       if (profit != null) ...[
                        const Gap(6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: (isProfitPositive ? Colors.green : Colors.red)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: (isProfitPositive ? Colors.green : Colors.red)
                                .withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                               Icon(
                                isProfitPositive ? Icons.trending_up : Icons.trending_down,
                                size: 10,
                                color: isProfitPositive ? Colors.green : Colors.red
                               ),
                               const Gap(4),
                              Text(
                                '%${NumberFormat('0.00', 'tr_TR').format(((profit / (asset.amount * asset.price)) * 100).abs())}',
                                style: TextStyle(
                                  color: isProfitPositive ? Colors.green : Colors.red,
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
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                       decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                       ),
                      child: Text(
                        '${_formatAmount(asset.amount)} adet',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white
                        ),
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '₺${NumberFormat('#,##0.00', 'tr_TR').format(asset.price)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                    if (profit != null) ...[
                      const Gap(2),
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
        ],
      ),
    );
  }

  void _showAssetActionsSheet(Asset asset) {
    final state = ref.read(assetProvider);
    double availableBalance = 0;
    if (state is AssetLoaded) {
      final sameCurrencyAssets = state.assets.where(
        (a) => a.currencyId == asset.currencyId,
      );
      final totalBuys = sameCurrencyAssets
          .where((a) => a.type == 'buy')
          .fold<double>(0, (sum, a) => sum + a.amount);
      final totalSells = sameCurrencyAssets
          .where((a) => a.type == 'sell')
          .fold<double>(0, (sum, a) => sum + a.amount);
      availableBalance = totalBuys - totalSells;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          image: DecorationImage(
             image: AssetImage('assets/images/noise.png'),
             opacity: 0.05,
             fit: BoxFit.cover,
          ),
          color: AppTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
             BoxShadow(color: Colors.black26, blurRadius: 40, spreadRadius: 10),
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
             const Gap(24),
            Row(
              children: [
                 Container(
                   padding: const EdgeInsets.all(12),
                   decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2))
                   ),
                   child: Icon(asset.currency?.isGold == true ? Icons.workspace_premium : Icons.currency_exchange, color: AppTheme.gold, size: 24),
                 ),
                 const Gap(16),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        Text(
                          _getCurrencyDisplayName(asset),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          '${_formatAmount(asset.amount)} adet • ₺${NumberFormat('#,##0.00', 'tr_TR').format(asset.price)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                          ),
                        ),
                     ],
                   ),
                 )
              ],
            ),

            const Gap(32),
            if (asset.type == 'buy' && availableBalance > 0) ...[
              _buildActionTile(
                icon: Icons.sell_outlined,
                label: 'Sat',
                subtitle: 'Bu varlığı satışa çıkar',
                onTap: () {
                  Navigator.pop(ctx);
                  _showSellSheet(asset);
                },
              ),
              const Gap(12),
            ],
            _buildActionTile(
              icon: Icons.delete_outline,
              label: 'Sil',
              subtitle: 'Bu kaydı kalıcı olarak sil',
              isDestructive: true,
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteConfirmSheet(asset);
              },
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDestructive ? Colors.red : AppTheme.gold).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : AppTheme.gold,
                size: 22,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDestructive ? Colors.red : Colors.white,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.2),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return NumberFormat('#,##0.##', 'tr_TR').format(value);
  }

  String _getCurrencyDisplayName(asset) {
    final currency = asset.currency;
    if (currency == null) return 'Varlık';
    return currency.isGold ? currency.name : currency.code;
  }

  void _showSellSheet(Asset asset) {
    final amountController = TextEditingController();
    final priceController = TextEditingController(
      text: (asset.currency?.selling ?? asset.price).toStringAsFixed(2),
    );

    final state = ref.read(assetProvider);
    double availableBalance = asset.amount;
    if (state is AssetLoaded) {
      final sameCurrencyAssets = state.assets.where(
        (a) => a.currencyId == asset.currencyId,
      );
      final totalBuys = sameCurrencyAssets
          .where((a) => a.type == 'buy')
          .fold<double>(0, (sum, a) => sum + a.amount);
      final totalSells = sameCurrencyAssets
          .where((a) => a.type == 'sell')
          .fold<double>(0, (sum, a) => sum + a.amount);
      availableBalance = totalBuys - totalSells;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Varlık Sat',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Gap(8),
              Text(
                asset.currency?.isGold == true
                    ? (asset.currency?.name ?? '')
                    : (asset.currency?.code ?? ''),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              ),
              const Gap(24),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Miktar',
                  hintText: 'Maks: ${_formatAmount(availableBalance)}',
                  prefixIcon: const Icon(Icons.balance_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const Gap(16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Satış Fiyatı',
                  prefixIcon: const Icon(Icons.payments_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const Gap(32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final amountText = amountController.text.trim();
                    final priceText = priceController.text.trim();

                    if (amountText.isEmpty) {
                      AppNotification.show(
                        ctx,
                        message: 'Lütfen satılacak miktarı girin',
                        type: NotificationType.error,
                      );
                      return;
                    }

                    if (priceText.isEmpty) {
                      AppNotification.show(
                        ctx,
                        message: 'Lütfen satış fiyatını girin',
                        type: NotificationType.error,
                      );
                      return;
                    }

                    final amount =
                        double.tryParse(amountText.replaceAll(',', '.')) ?? 0;
                    final price =
                        double.tryParse(priceText.replaceAll(',', '.')) ?? 0;

                    if (amount <= 0) {
                      AppNotification.show(
                        ctx,
                        message: 'Miktar 0\'dan büyük olmalıdır',
                        type: NotificationType.error,
                      );
                      return;
                    }
                    if (price <= 0) {
                      AppNotification.show(
                        ctx,
                        message: 'Satış fiyatı 0\'dan büyük olmalıdır',
                        type: NotificationType.error,
                      );
                      return;
                    }
                    if (amount > availableBalance) {
                      AppNotification.show(
                        ctx,
                        message:
                            'Mevcut miktardan fazla satamazsınız (Maks: ${_formatAmount(availableBalance)})',
                        type: NotificationType.error,
                      );
                      return;
                    }

                    ref
                        .read(assetProvider.notifier)
                        .sellAssetById(
                          currencyId: asset.currencyId,
                          amount: amount,
                          price: price,
                        );
                    Navigator.pop(ctx);
                    AppNotification.show(
                      context,
                      message: 'Satış işlemi kaydedildi',
                      type: NotificationType.success,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Satışı Onayla', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmSheet(Asset asset) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
                  const Gap(24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                  const Gap(24),
                  const Text(
                    'İşlemi Onayla',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const Gap(12),
                  Text(
                    'Bu işlem geri alınamaz. "${asset.currency!.isGold ? asset.currency?.name : asset.currency?.code}" kaydını silmek istediğinize emin misiniz?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const Gap(32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Vazgeç'),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  setSheetState(() => isLoading = true);
                                  final success = await ref
                                      .read(assetProvider.notifier)
                                      .deleteAsset(asset.id);
                                  if (context.mounted) {
                                    Navigator.pop(ctx);
                                    if (success) {
                                      AppNotification.show(
                                        context,
                                        message: 'Kayıt silindi',
                                        type: NotificationType.success,
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Evet, Sil'),
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(color: AppTheme.gold, strokeWidth: 2),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Shimmer.fromColors(
          baseColor: AppTheme.surface,
          highlightColor: Colors.white10,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
    );
  }
}
