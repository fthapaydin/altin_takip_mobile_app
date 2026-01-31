import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/core/storage/storage_service.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/assets/presentation/asset_notifier.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';
import 'package:altin_takip/features/auth/presentation/auth_notifier.dart';
import 'package:altin_takip/features/settings/presentation/preference_notifier.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:altin_takip/features/currencies/presentation/history/currency_history_screen.dart';
import 'package:altin_takip/features/assets/presentation/add_asset_screen.dart';

// Extracted Widgets
import 'package:altin_takip/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/portfolio_summary_card.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/dashboard_general_tab.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/dashboard_assets_tab.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  List<String> _goldOrder = [];
  List<String> _forexOrder = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final state = ref.read(assetProvider);
      // Only trigger loading if we don't have dashboard data already
      if (state is! AssetLoaded || state.dashboardData == null) {
        ref.read(assetProvider.notifier).loadDashboard(refresh: true);
      }
      await _loadSavedOrders();
    });
  }

  Future<void> _loadSavedOrders() async {
    final storageService = sl<StorageService>();
    final savedGoldOrder = await storageService.getDashboardGoldOrder();
    final savedForexOrder = await storageService.getDashboardForexOrder();

    if (mounted) {
      setState(() {
        _goldOrder = savedGoldOrder ?? [];
        _forexOrder = savedForexOrder ?? [];
      });
    }
  }

  Future<void> _saveGoldOrder(List<String> order) async {
    setState(() {
      _goldOrder = order;
    });
    await sl<StorageService>().saveDashboardGoldOrder(_goldOrder);
  }

  Future<void> _saveForexOrder(List<String> order) async {
    setState(() {
      _forexOrder = order;
    });
    await sl<StorageService>().saveDashboardForexOrder(_forexOrder);
  }

  void _navigateToHistory(Currency currency, bool isGold) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CurrencyHistoryScreen(
          currencyCode: currency.code,
          currencyId: currency.id.toString(),
          currencyName: currency.name,
          isGold: isGold,
        ),
      ),
    );
  }

  void _showAddAssetScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAssetScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assetState = ref.watch(assetProvider);
    final authState = ref.watch(authProvider);

    // Listen for errors with custom notification
    ref.listen<AssetState>(assetProvider, (previous, next) {
      if (next is AssetError) {
        AppNotification.show(
          context,
          message: next.message,
          type: NotificationType.error,
        );
      }
    });

    ref.listen<PreferenceState>(preferenceProvider, (prev, next) {
      if (prev?.resetToken != next.resetToken) {
        _loadSavedOrders();
      }
    });

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(assetProvider.notifier).loadDashboard(refresh: true),
            color: AppTheme.gold,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DashboardHeader(authState: authState),
                        const Gap(32),
                        PortfolioSummaryCard(state: assetState),
                        const Gap(32),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      isScrollable: false,
                      labelColor: Colors.black, // Text on Gold
                      unselectedLabelColor: Colors.white, // Text on Glass
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      indicator: BoxDecoration(
                        color: AppTheme.gold,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      overlayColor: MaterialStateProperty.all(
                        Colors.transparent,
                      ),
                      tabs: const [
                        Tab(text: 'Genel'),
                        Tab(text: 'Altın'),
                        Tab(text: 'Döviz'),
                      ],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                children: [
                  DashboardGeneralTab(
                    state: assetState,
                    onNavigateToHistory: _navigateToHistory,
                    onShowAddAsset: _showAddAssetScreen,
                  ),
                  DashboardAssetsTab(
                    state: assetState,
                    type: 'Altın',
                    currentOrder: _goldOrder,
                    onNavigateToHistory: _navigateToHistory,
                    onReorder: _saveGoldOrder,
                  ),
                  DashboardAssetsTab(
                    state: assetState,
                    type: 'Forex',
                    currentOrder: _forexOrder,
                    onNavigateToHistory: _navigateToHistory,
                    onReorder: _saveForexOrder,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height + 24; // Added padding
  @override
  double get maxExtent => _tabBar.preferredSize.height + 24; // Added padding

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppTheme.background, // Match background to hide content behind
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.glassColor,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
