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
import 'package:altin_takip/features/assets/presentation/add_asset_screen.dart';
import 'package:altin_takip/features/settings/presentation/preference_notifier.dart';
import 'package:altin_takip/features/dashboard/presentation/transactions_screen.dart';
import 'package:altin_takip/features/auth/presentation/auth_notifier.dart';
import 'package:altin_takip/features/auth/presentation/auth_state.dart';
import 'package:altin_takip/features/auth/presentation/encryption_screen.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/features/assets/presentation/widgets/locked_portfolio_view.dart';
import 'package:altin_takip/features/assets/presentation/widgets/empty_assets_view.dart';
import 'package:altin_takip/features/assets/presentation/widgets/shimmer_loading_list.dart';
import 'package:altin_takip/features/assets/presentation/widgets/asset_group_card.dart';
import 'package:altin_takip/core/widgets/app_bar_widget.dart';

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
      final state = ref.read(assetProvider);
      // Only trigger loading if we don't have assets already
      if (state is! AssetLoaded) {
        ref.read(assetProvider.notifier).loadAllAssets();
      }
      await _loadSavedOrder();
    });
    _scrollController.addListener(_onScroll);

    // Auto-prompt for encryption if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState is AuthEncryptionRequired) {
        _showEncryptionScreen();
      }
    });
  }

  void _showEncryptionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EncryptionScreen()),
    );
  }

  Future<void> _loadSavedOrder() async {
    final storageService = sl<StorageService>();
    final savedOrder = await storageService.getAssetOrder();
    if (mounted) {
      setState(() {
        _customOrder = savedOrder ?? [];
        _orderLoaded = true;
      });
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

  void _showAddAssetScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAssetScreen()),
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

    ref.listen<PreferenceState>(preferenceProvider, (prev, next) {
      if (prev?.resetToken != next.resetToken) {
        _loadSavedOrder();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBarWidget(
        title: 'Varlıklarım',
        showBack: false,
        centerTitle: false,
        isLargeTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionsScreen(),
                ),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: const Icon(
                Iconsax.receipt_1,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const Gap(8),
          IconButton(
            onPressed: _showAddAssetScreen,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.gold,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gold.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Iconsax.add, color: Colors.black, size: 20),
            ),
          ),
          const Gap(16),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (state is AssetLoaded && state.isRefreshing)
              LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: AppTheme.gold.withValues(alpha: 0.3),
                minHeight: 2,
              ),
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AssetState state) {
    final authState = ref.watch(authProvider);
    if (authState is AuthEncryptionRequired) {
      return const LockedPortfolioView();
    }

    if (state is AssetLoading || !_orderLoaded) {
      return const ShimmerLoadingList();
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
        return const EmptyAssetsView();
      }

      final groupedAssets = _groupAssets(state.assets);
      final sortedGroups = _getSortedGroups(groupedAssets);

      return RefreshIndicator(
        onRefresh: () =>
            ref.read(assetProvider.notifier).loadAllAssets(refresh: true),
        color: AppTheme.gold,
        child: ReorderableListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
          itemCount: sortedGroups.length,
          proxyDecorator: (child, index, animation) {
            return Material(
              color: Colors.transparent,
              elevation: 8,
              shadowColor: Colors.black54,
              borderRadius: BorderRadius.circular(16),
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
            final currencyCode = entry.key;
            final isExpanded = _expandedGroups.contains(currencyCode);

            return AssetGroupCard(
              key: ValueKey(currencyCode),
              index: index,
              currencyCode: currencyCode,
              assets: entry.value,
              isExpanded: isExpanded,
              onToggle: () {
                setState(() {
                  if (isExpanded) {
                    _expandedGroups.remove(currencyCode);
                  } else {
                    _expandedGroups.add(currencyCode);
                  }
                });
              },
            );
          },
        ),
      );
    }

    return const SizedBox();
  }
}
