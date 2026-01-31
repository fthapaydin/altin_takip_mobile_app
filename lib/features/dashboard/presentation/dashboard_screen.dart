import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/core/storage/storage_service.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/utils/date_formatter.dart';
import 'package:altin_takip/features/assets/presentation/asset_notifier.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';
import 'package:altin_takip/features/auth/presentation/auth_notifier.dart';
import 'package:altin_takip/features/auth/presentation/auth_state.dart';
import 'package:altin_takip/features/settings/presentation/preference_notifier.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:altin_takip/features/dashboard/presentation/transactions_screen.dart';
import 'package:altin_takip/features/currencies/presentation/history/currency_history_screen.dart';
import 'package:altin_takip/features/assets/presentation/add_asset_screen.dart';
import 'package:altin_takip/core/widgets/currency_icon.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/portfolio_chart.dart';

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
        ref.read(assetProvider.notifier).loadDashboard();
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
        if (savedGoldOrder != null) _goldOrder = savedGoldOrder;
        if (savedForexOrder != null) _forexOrder = savedForexOrder;
      });
    }
  }

  Future<void> _saveGoldOrder() async {
    await sl<StorageService>().saveDashboardGoldOrder(_goldOrder);
  }

  Future<void> _saveForexOrder() async {
    await sl<StorageService>().saveDashboardForexOrder(_forexOrder);
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

  List<Currency> _getSortedCurrencies(List<Currency> currencies, bool isGold) {
    final order = isGold ? _goldOrder : _forexOrder;
    if (order.isEmpty) return currencies;

    final sorted = List<Currency>.from(currencies);
    sorted.sort((a, b) {
      final indexA = order.indexOf(a.code);
      final indexB = order.indexOf(b.code);

      if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);
      if (indexA != -1) return -1;
      if (indexB != -1) return 1;
      return 0;
    });

    // Update order with new items or remove obsolete ones
    final currentCodes = sorted.map((c) => c.code).toList();
    if (isGold) {
      _goldOrder = currentCodes;
      _saveGoldOrder();
    } else {
      _forexOrder = currentCodes;
      _saveForexOrder();
    }

    return sorted;
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
                        _buildHeader(context, authState),
                        const Gap(32),
                        _buildPortfolioCard(context, assetState),
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
                  _buildGenelTab(assetState),
                  _buildCategorizedTab(assetState, 'Altın'),
                  _buildCategorizedTab(
                    assetState,
                    'Forex',
                  ), // Assuming non-gold is Forex
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthState authState) {
    final user = authState is AuthAuthenticated ? authState.user : null;
    final isEncrypted = user?.isEncrypted ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Merhaba, ${user?.formattedName ?? "Misafir"}',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (isEncrypted) ...[
                  const Gap(8),
                  const Icon(
                    Icons.enhanced_encryption,
                    color: AppTheme.gold,
                    size: 18,
                  ),
                ],
              ],
            ),
            Text(
              DateFormat('d MMMM yyyy', 'tr_TR').format(DateTime.now()),
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.surface,
          child: Icon(
            isEncrypted ? Icons.shield : Icons.person,
            color: AppTheme.gold,
          ),
        ),
      ],
    ).animate().fadeIn().slideX();
  }

  Widget _buildPortfolioCard(BuildContext context, AssetState state) {
    if (state is AssetLoading) {
      return _buildPortfolioShimmer();
    }

    // Use dashboard data if available, otherwise calculate from assets
    final dashboardSummary = (state is AssetLoaded)
        ? state.dashboardData?.summary
        : null;
    final chartData = (state is AssetLoaded)
        ? state.dashboardData?.chartData
        : null;

    final totalWorth =
        dashboardSummary?.totalValue ??
        (state is AssetLoaded ? _calculateTotalWorth(state) : 0.0);
    final profitLoss =
        dashboardSummary?.profitLoss ??
        (state is AssetLoaded ? _calculateProfitLoss(state) : 0.0);
    final profitPercentage =
        dashboardSummary?.profitLossPercentage ??
        ((totalWorth - profitLoss) > 0
            ? (profitLoss / (totalWorth - profitLoss)) * 100
            : 0.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.luxuryGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Chart background (semi-transparent)
          if (chartData != null && chartData.isNotEmpty)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 20,
                ),
                child: PortfolioChart(chartData: chartData),
              ),
            ),

          // Content overlay
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Toplam Portföy Değeri',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (profitLoss >= 0 ? Colors.green : Colors.red)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (profitLoss >= 0 ? Colors.green : Colors.red)
                            .withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          profitLoss >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: profitLoss >= 0 ? Colors.green : Colors.red,
                          size: 14,
                        ),
                        const Gap(6),
                        Text(
                          '%${NumberFormat('#,##0.1', 'tr_TR').format(profitPercentage.abs())}',
                          style: TextStyle(
                            fontFeatures: const [FontFeature.tabularFigures()],
                            color: profitLoss >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(16),
              Text(
                '₺${NumberFormat('#,##0.00', 'tr_TR').format(totalWorth)}',
                style: const TextStyle(
                  fontFeatures: [FontFeature.tabularFigures()],
                  fontWeight: FontWeight.w300, // Thin luxury look
                  color: Colors.white,
                  fontSize: 42, // Hero size
                  letterSpacing: -1.5,
                ),
              ),
              const Gap(24),
              _buildDistributionBar(state),
              const Gap(24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.glassColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Toplam Kar/Zarar',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${profitLoss >= 0 ? "+" : ""}₺${NumberFormat('#,##0.00', 'tr_TR').format(profitLoss)}',
                      style: TextStyle(
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: profitLoss >= 0
                            ? Color(0xFF4ADE80)
                            : Color(0xFFF87171), // Softer Green/Red
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionBar(AssetState state) {
    if (state is! AssetLoaded) return const SizedBox();

    double goldValue = 0;
    double forexValue = 0;

    final Map<int, double> holdings = {};
    for (var asset in state.assets) {
      final amount = asset.amount;
      if (asset.type == 'buy') {
        holdings[asset.currencyId] = (holdings[asset.currencyId] ?? 0) + amount;
      } else {
        holdings[asset.currencyId] = (holdings[asset.currencyId] ?? 0) - amount;
      }
    }

    holdings.forEach((currencyId, amount) {
      final currency = state.currencies.firstWhere(
        (c) => c.id == currencyId,
        orElse: () => state.currencies.first,
      );
      final value = amount * currency.selling;
      if (currency.type == 'Altın') {
        goldValue += value;
      } else {
        forexValue += value;
      }
    });

    final total = goldValue + forexValue;
    if (total == 0) return const SizedBox();

    final goldWidth = (goldValue / total);
    final forexWidth = (forexValue / total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Altın %${(goldWidth * 100).toInt()}',
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
            Text(
              'Döviz %${(forexWidth * 100).toInt()}',
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
        const Gap(6),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            children: [
              if (goldWidth > 0)
                Expanded(
                  flex: (goldWidth * 100).toInt(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.gold,
                      borderRadius: BorderRadius.horizontal(
                        left: const Radius.circular(3),
                        right: Radius.circular(forexWidth == 0 ? 3 : 0),
                      ),
                    ),
                  ),
                ),
              if (forexWidth > 0)
                Expanded(
                  flex: (forexWidth * 100).toInt(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(goldWidth == 0 ? 3 : 0),
                        right: const Radius.circular(3),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface,
      highlightColor: Colors.white10,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Widget _buildGenelTab(AssetState state) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverGap(24),
        SliverToBoxAdapter(child: _buildSectionTitle('Günün Özeti')),
        const SliverGap(16),
        if (state is AssetLoading)
          SliverToBoxAdapter(child: _buildCarouselShimmer())
        else if (state is AssetLoaded)
          SliverToBoxAdapter(
            child: _buildCurrencyCarousel(_getPersonalizedCurrencies(state)),
          ),
        const SliverGap(40),
        SliverToBoxAdapter(
          child: _buildSectionTitle(
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
        _buildTransactionList(state),
        const SliverGap(100),
      ],
    );
  }

  Widget _buildCategorizedTab(AssetState state, String type) {
    if (state is AssetLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppTheme.gold),
            const Gap(16),
            Text(
              'Kurlar yükleniyor...',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ],
        ),
      );
    }
    if (state is AssetLoaded) {
      final isGoldTab = type == 'Altın';
      final filteredCurrencies = state.currencies.where((c) {
        if (isGoldTab) return c.isGold;
        return !c.isGold;
      }).toList();

      final sortedCurrencies = _getSortedCurrencies(
        filteredCurrencies,
        isGoldTab,
      );

      return ReorderableListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
        itemCount: sortedCurrencies.length,
        proxyDecorator: (child, index, animation) {
          return Material(
            color: Colors.transparent,
            elevation: 4,
            shadowColor: AppTheme.gold.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            child: child,
          );
        },
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex--;
            final item = sortedCurrencies.removeAt(oldIndex);
            sortedCurrencies.insert(newIndex, item);

            final newOrder = sortedCurrencies.map((c) => c.code).toList();
            if (isGoldTab) {
              _goldOrder = newOrder;
              _saveGoldOrder();
            } else {
              _forexOrder = newOrder;
              _saveForexOrder();
            }
          });
        },
        itemBuilder: (context, index) {
          final currency = sortedCurrencies[index];
          return Container(
            key: ValueKey(currency.code),
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildPremiumCurrencyCard(
              currency,
              isGold: isGoldTab,
              index: index,
            ),
          );
        },
      );
    }
    return const SizedBox();
  }

  Widget _buildPremiumCurrencyCard(
    Currency currency, {
    required bool isGold,
    required int index,
  }) {
    final useDynamicDate = ref.watch(preferenceProvider).useDynamicDate;
    final priceChange = currency.selling - currency.buying;
    final isPositive = priceChange >= 0;

    return GestureDetector(
      onTap: () => _navigateToHistory(currency, isGold),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.gold.withOpacity(0.2),
                      AppTheme.gold.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24), // Perfect circle
                  border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
                ),
                child: CurrencyIcon(
                  iconUrl: currency.iconUrl,
                  isGold: isGold,
                  size: 48, // Match container size
                  color: AppTheme.gold,
                ),
              ),
              const Gap(16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGold ? currency.name : currency.code,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Text(
                      DateFormatter.format(
                        currency.lastUpdatedAt,
                        useDynamic: useDynamicDate,
                      ),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Prices
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '₺${NumberFormat('#,##0.00', 'tr_TR').format(currency.selling)}',
                    style: const TextStyle(
                      fontFeatures: [FontFeature.tabularFigures()],
                      color: AppTheme.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Gap(4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Alış: ₺${NumberFormat('#,##0.00', 'tr_TR').format(currency.buying)}',
                        style: TextStyle(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (isPositive ? Colors.green : Colors.red)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${isPositive ? "+" : ""}%${NumberFormat('#,##0.00', 'tr_TR').format((priceChange / currency.buying) * 100)}',
                          style: TextStyle(
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontSize: 10,
                            color: isPositive
                                ? Color(0xFF4ADE80)
                                : Color(0xFFF87171),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Deprecated: Use _buildPremiumCurrencyCard instead
  // Widget _buildCurrencyListItem is no longer used

  Widget _buildSectionTitle(
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
            style: context.textTheme.titleLarge?.copyWith(
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
                  Icon(Icons.arrow_forward, size: 14),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrencyCarousel(List<Currency> currencies) {
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
                    Icons.stacked_line_chart,
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
            onTap: () => _navigateToHistory(currency, currency.isGold),
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

  Widget _buildTransactionList(AssetState state) {
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
                    Icons.savings_outlined,
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
                  onPressed: () => _showAddAssetScreen(context),
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
          final isBuy = asset.type == 'buy';
          final currentPrice = asset.currency?.selling ?? asset.price;
          final diff = (currentPrice - asset.price) * asset.amount;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      color: isBuy ? Colors.green : Colors.red,
                    ),
                    const Gap(14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              asset.currency?.name ?? 'Bilinmeyen Varlık',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              DateFormat(
                                'd MMM yyyy',
                                'tr_TR',
                              ).format(asset.date),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.35),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.gold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${NumberFormat('#,##0.##', 'tr_TR').format(asset.amount)} adet',
                              style: const TextStyle(
                                color: AppTheme.gold,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const Gap(4),
                          Text(
                            '${diff >= 0 ? "+" : ""}₺${NumberFormat('#,##0.00', 'tr_TR').format(diff)}',
                            style: TextStyle(
                              color: diff >= 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }, childCount: displayAssets.length),
      );
    }
    return const SliverToBoxAdapter(child: SizedBox());
  }

  double _calculateTotalWorth(AssetLoaded state) {
    if (state.assets.isEmpty || state.currencies.isEmpty) return 0.0;

    double currentTotalValue = 0;
    final Map<int, double> holdings = {};

    // Calculate net holdings per currency
    for (var asset in state.assets) {
      final amount = asset.amount;
      if (asset.type == 'buy') {
        holdings[asset.currencyId] = (holdings[asset.currencyId] ?? 0) + amount;
      } else {
        holdings[asset.currencyId] = (holdings[asset.currencyId] ?? 0) - amount;
      }
    }

    // Multiply net holdings by current selling price
    holdings.forEach((currencyId, amount) {
      try {
        // Find currency in loaded list or use the one from assets if not there
        final currency = state.currencies.firstWhere(
          (c) => c.id == currencyId,
          orElse: () {
            final asset = state.assets.firstWhere(
              (a) => a.currencyId == currencyId,
            );
            if (asset.currency != null) return asset.currency!;
            throw Exception('Currency not found');
          },
        );
        currentTotalValue += amount * currency.selling;
      } catch (_) {
        // Fallback for missing currency info
      }
    });

    return currentTotalValue;
  }

  double _calculateProfitLoss(AssetLoaded state) {
    double totalCost = 0;
    double currentVal = 0;

    for (var asset in state.assets) {
      if (asset.type == 'buy') {
        totalCost += asset.amount * asset.price;
        final currentPrice = asset.currency?.selling ?? asset.price;
        currentVal += asset.amount * currentPrice;
      } else {
        totalCost -= asset.amount * asset.price;
        final currentPrice = asset.currency?.buying ?? asset.price;
        currentVal -= asset.amount * currentPrice;
      }
    }

    return currentVal - totalCost;
  }

  void _showAddAssetScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAssetScreen()),
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

int min(int a, int b) => a < b ? a : b;
