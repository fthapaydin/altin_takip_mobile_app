import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/public_prices/presentation/public_prices_state.dart';
import 'package:altin_takip/features/public_prices/presentation/public_prices_notifier.dart';
import 'package:altin_takip/features/public_prices/domain/public_price.dart';
import 'package:altin_takip/features/public_prices/domain/public_prices_repository.dart';
import 'package:altin_takip/features/public_prices/presentation/public_price_detail_screen.dart';
import 'package:altin_takip/features/auth/presentation/login_screen.dart';
import 'package:altin_takip/features/auth/presentation/register_screen.dart';
import 'package:iconsax/iconsax.dart';

final publicPricesRepositoryProvider = Provider<PublicPricesRepository>((ref) => sl());

final publicPricesProvider =
    NotifierProvider<PublicPricesNotifier, PublicPricesState>(
  PublicPricesNotifier.new,
);

class PublicHomeScreen extends ConsumerStatefulWidget {
  const PublicHomeScreen({super.key});

  @override
  ConsumerState<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends ConsumerState<PublicHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(publicPricesProvider.notifier).loadPrices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(publicPricesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(publicPricesProvider.notifier).loadPrices(refresh: true),
            color: AppTheme.gold,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const Gap(24),
                        _buildAuthButtons(context),
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
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.white,
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
                        Tab(text: 'Döviz'),
                        Tab(text: 'Altın'),
                      ],
                    ),
                  ),
                ),
              ],
              body: state is PublicPricesLoaded
                  ? TabBarView(
                      children: [
                        _buildPriceList(state.data.currencies),
                        _buildPriceList(state.data.goldPrices),
                      ],
                    )
                  : state is PublicPricesLoading
                      ? _buildLoadingView()
                      : state is PublicPricesError
                          ? _buildErrorView(state.message)
                          : _buildLoadingView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Biriktirerek',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.gold,
                letterSpacing: 0.5,
              ),
        ),
        const Gap(8),
        Text(
          'Anlık piyasa fiyatları',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.6),
              ),
        ),
      ],
    );
  }

  Widget _buildAuthButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.gold,
              side: const BorderSide(color: AppTheme.gold),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Giriş Yap',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Kayıt Ol',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceList(List<PublicPrice> prices) {
    if (prices.isEmpty) {
      return Center(
        child: Text(
          'Veri bulunamadı',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      itemCount: prices.length,
      separatorBuilder: (_, __) => Divider(
        color: Colors.white.withOpacity(0.05),
        height: 1,
      ),
      itemBuilder: (context, index) {
        final price = prices[index];
        return _buildPriceRow(price);
      },
    );
  }

  Widget _buildPriceRow(PublicPrice price) {
    final changeValue = price.change.replaceAll('%', '').replaceAll(',', '.');
    final changeNum = double.tryParse(changeValue) ?? 0;
    final isPositive = changeNum >= 0;
    final changeColor = isPositive ? const Color(0xFF4ADE80) : const Color(0xFFF87171);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PublicPriceDetailScreen(price: price),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  Text(
                    price.code.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatPrice(price.buyPrice),
                    style: const TextStyle(
                      color: AppTheme.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const Gap(4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        isPositive ? Iconsax.arrow_up_3 : Iconsax.arrow_down,
                        color: changeColor,
                        size: 12,
                      ),
                      const Gap(4),
                      Text(
                        price.change,
                        style: TextStyle(
                          color: changeColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(8),
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

  String _formatPrice(String price) {
    // If price starts with $ or other currency symbol, return as is
    if (price.startsWith('\$') || price.startsWith('€')) {
      return price;
    }
    
    // Otherwise add TL symbol
    final cleanPrice = price.replaceAll(',', '.');
    final numValue = double.tryParse(cleanPrice);
    if (numValue != null) {
      return '₺${NumberFormat('#,##0.00', 'tr_TR').format(numValue)}';
    }
    return price;
  }

  Widget _buildLoadingView() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      itemCount: 10,
      separatorBuilder: (_, __) => const Gap(12),
      itemBuilder: (_, __) => Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.glassColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.white.withOpacity(0.05),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Gap(8),
                        Container(
                          width: 100,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Gap(8),
                        Container(
                          width: 100,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF87171).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.info_circle,
                color: Color(0xFFF87171),
                size: 48,
              ),
            ),
            const Gap(16),
            Text(
              'Bir Hata Oluştu',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Gap(8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const Gap(24),
            ElevatedButton(
              onPressed: () {
                ref.read(publicPricesProvider.notifier).loadPrices(refresh: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Tekrar Dene',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height + 24;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 24;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppTheme.background,
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
