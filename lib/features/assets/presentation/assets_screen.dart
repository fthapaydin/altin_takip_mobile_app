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
      // Initialize order from grouped keys
      _customOrder = grouped.keys.toList();
    }

    // Add any new keys not in customOrder
    for (final key in grouped.keys) {
      if (!_customOrder.contains(key)) {
        _customOrder.add(key);
      }
    }

    // Remove keys that no longer exist
    _customOrder.removeWhere((key) => !grouped.containsKey(key));

    // Sort by custom order
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
        // Handle persistent state error
        AppNotification.show(
          context,
          message: next.actionError!,
          type: NotificationType.error,
        );
        // Clear the error after showing it to prevent repeated notifications
        // Ideally, we might want a method in notifier to clear this,
        // but for now, it's a one-off event.
        // A better approach would be treating actionError as an ephemeral event stream,
        // but given the architecture, this works if we assume the user will retry or the state refreshes.
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: const Text(
          'Portföyüm',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: _buildBody(state),
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
          scrollController: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
          itemCount: sortedGroups.length,
          proxyDecorator: (child, index, animation) {
            return Material(
              color: Colors.transparent,
              elevation: 4,
              shadowColor: AppTheme.gold.withOpacity(0.3),
              borderRadius: BorderRadius.circular(14),
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

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
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
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Drag handle
                  ReorderableDragStartListener(
                    index: _customOrder.indexOf(currencyCode),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      margin: const EdgeInsets.only(right: 10),
                      child: Icon(
                        Icons.drag_indicator,
                        color: Colors.white.withOpacity(0.3),
                        size: 18,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isGold
                          ? Icons.workspace_premium
                          : Icons.currency_exchange,
                      color: AppTheme.gold,
                      size: 20,
                    ),
                  ),
                  const Gap(14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGold
                              ? (currency?.name ?? currencyCode)
                              : currencyCode,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          '${assets.length} işlem',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_formatAmount(totalAmount)} adet',
                          style: const TextStyle(
                            color: AppTheme.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '₺${NumberFormat('#,##0.00', 'tr_TR').format(totalValue.abs())}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable transactions - grouped by buy/sell
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildGroupedTransactions(assets),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedTransactions(List<Asset> assets) {
    final buys = assets.where((a) => a.type == 'buy').toList();
    final sells = assets.where((a) => a.type == 'sell').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.white.withOpacity(0.05), height: 1),
        // Buys section
        if (buys.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const Gap(8),
                Text(
                  'Alışlar (${buys.length})',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...buys.map((asset) => _buildTransactionItem(asset)),
        ],
        // Sells section
        if (sells.isNotEmpty) ...[
          if (buys.isNotEmpty)
            Divider(color: Colors.white.withOpacity(0.03), height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const Gap(8),
                Text(
                  'Satışlar (${sells.length})',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...sells.map((asset) => _buildTransactionItem(asset)),
        ],
      ],
    );
  }

  Widget _buildTransactionItem(Asset asset) {
    final isBuy = asset.type == 'buy';
    final useDynamicDate = ref.watch(preferenceProvider).useDynamicDate;
    final formattedDate = DateFormatter.format(
      asset.date,
      useDynamic: useDynamicDate,
    );

    return InkWell(
      onTap: () => _showAssetActionsSheet(asset),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: isBuy ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBuy ? 'Alış' : 'Satış',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: isBuy ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_formatAmount(asset.amount)} adet',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '₺${NumberFormat('#,##0.00', 'tr_TR').format(asset.price)}/birim',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const Gap(8),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: Colors.white.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssetActionsSheet(Asset asset) {
    // Calculate available balance for this currency
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
          color: AppTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getCurrencyDisplayName(asset),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Gap(8),
            Text(
              '${_formatAmount(asset.amount)} adet • ₺${NumberFormat('#,##0.00', 'tr_TR').format(asset.price)}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
            const Gap(24),
            // Only show Sell option for buy transactions AND if there's available balance
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
            const Gap(16),
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isDestructive ? Colors.red : AppTheme.gold).withOpacity(
                  0.1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : AppTheme.gold,
                size: 20,
              ),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDestructive ? Colors.red : Colors.white,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.3),
              size: 20,
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

    // Calculate available balance: total buys - total sells for this currency
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
              const Gap(20),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Miktar (Maks: ${_formatAmount(availableBalance)})',
                  prefixIcon: const Icon(Icons.balance_outlined, size: 20),
                ),
              ),
              const Gap(12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Satış Fiyatı',
                  prefixIcon: Icon(Icons.payments_outlined, size: 20),
                ),
              ),
              const Gap(24),
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
                  child: const Text('Satışı Onayla'),
                ),
              ),
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),
                  const Gap(20),
                  const Text(
                    'İşlemi Onayla',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Gap(8),
                  Text(
                    'Bu işlem geri alınamaz. "${asset.currency!.isGold ? asset.currency?.name : asset.currency?.code}" kaydını silmek istediğinize emin misiniz?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                  const Gap(24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Vazgeç'),
                        ),
                      ),
                      const Gap(12),
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Shimmer.fromColors(
          baseColor: AppTheme.surface,
          highlightColor: Colors.white10,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
