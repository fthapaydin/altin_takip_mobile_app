import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/public_prices/presentation/public_prices_state.dart';
import 'package:altin_takip/features/public_prices/presentation/public_prices_notifier.dart';
import 'package:altin_takip/features/public_prices/domain/public_prices_repository.dart';
import 'package:altin_takip/features/public_prices/presentation/widgets/public_price_list_view.dart';
import 'package:altin_takip/features/public_prices/presentation/widgets/public_prices_loading_view.dart';
import 'package:altin_takip/features/public_prices/presentation/widgets/public_prices_error_view.dart';
import 'package:altin_takip/features/auth/presentation/login_screen.dart';
import 'package:altin_takip/features/auth/presentation/register_screen.dart';

final publicPricesRepositoryProvider = Provider<PublicPricesRepository>(
  (ref) => sl(),
);

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

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(publicPricesProvider.notifier).loadPrices(refresh: true),
          color: AppTheme.gold,
          child: DefaultTabController(
            length: 2,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const Gap(40),
                        _buildTitle(),
                        const Gap(24),
                        _buildPromoCard(context),
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
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w400,
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
              body: switch (state) {
                PublicPricesLoaded(:final data) => TabBarView(
                  children: [
                    PublicPriceListView(prices: data.currencies),
                    PublicPriceListView(prices: data.goldPrices),
                  ],
                ),
                PublicPricesLoading() => const PublicPricesLoadingView(),
                PublicPricesError(:final message) => PublicPricesErrorView(
                  message: message,
                  onRetry: () => ref
                      .read(publicPricesProvider.notifier)
                      .loadPrices(refresh: true),
                ),
                _ => const PublicPricesLoadingView(),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Iconsax.wallet_3,
                color: AppTheme.gold,
                size: 22,
              ),
            ),
            const Gap(12),
            const Text(
              'Altın Cüzdan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Icon(Iconsax.user, color: Colors.white, size: 22),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildTitle() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Piyasalar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w400,
                letterSpacing: -1,
              ),
            ),
            const Gap(8),
            Text(
              'Canlı döviz ve altın kurları',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: 100.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildPromoCard(BuildContext context) {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.glassColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ÜCRETSİZ',
                  style: TextStyle(
                    color: AppTheme.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Gap(16),
              const Text(
                'Portföyünüzü Yönetin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.5,
                ),
              ),
              const Gap(6),
              Text(
                'Varlıklarınızı ekleyerek kar zarar durumunuzu anlık takip edin.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Text(
                    'Kayıt Ol',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
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
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
