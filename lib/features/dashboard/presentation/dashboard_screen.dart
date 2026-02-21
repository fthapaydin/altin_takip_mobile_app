import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/core/storage/storage_service.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/assets/presentation/asset_notifier.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';
import 'package:altin_takip/features/settings/presentation/preference_notifier.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:altin_takip/features/currencies/presentation/history/currency_history_screen.dart';
import 'package:altin_takip/features/assets/presentation/add_asset_screen.dart';

import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altin_takip/core/widgets/app_bar_widget.dart';
import 'package:altin_takip/features/notifications/presentation/notifications_screen.dart';

// Extracted Widgets
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
        backgroundColor: AppTheme.background,
        appBar: AppBarWidget(
          title: 'Portföyüm',
          subtitle: DateFormat('d MMMM yyyy', 'tr_TR').format(DateTime.now()),
          showBack: false,
          centerTitle: false,
          isLargeTitle: true,
          actions: [
            _DashboardNotificationButton(),
            const Gap(4),
            _DashboardRefreshButton(),
            const Gap(16),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(assetProvider.notifier).loadDashboard(refresh: true),
            color: AppTheme.gold,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LoadingIndicator(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: PortfolioSummaryCard(state: assetState),
                      ),
                      const Gap(32),
                    ],
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
                        fontWeight: FontWeight.w400,
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

// ─────────────────────────────────────────────

class _DashboardNotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        );
      },
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.gold, AppTheme.gold.withValues(alpha: 0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.gold.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Iconsax.notification, size: 20, color: Colors.black),
      ),
    ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack);
  }
}

class _DashboardRefreshButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetState = ref.watch(assetProvider);
    final isLoading = assetState is AssetLoaded && assetState.isRefreshing;

    return IconButton(
      onPressed: () =>
          ref.read(assetProvider.notifier).loadDashboard(refresh: true),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isLoading ? Iconsax.timer_1 : Iconsax.refresh,
          size: 20,
          color: isLoading ? AppTheme.gold : Colors.white,
        ),
      ),
    );
  }
}

class _LoadingIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetState = ref.watch(assetProvider);
    final isLoading = assetState is AssetLoaded && assetState.isRefreshing;

    return AnimatedOpacity(
      opacity: isLoading ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: LinearProgressIndicator(
        backgroundColor: Colors.transparent,
        color: AppTheme.gold.withValues(alpha: 0.3),
        minHeight: 2,
      ),
    );
  }
}
