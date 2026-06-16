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
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUnifiedHeader(context),
                        const Gap(20),
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
                      labelColor: AppTheme.gold,
                      unselectedLabelColor: Colors.white.withOpacity(0.4),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                      indicatorColor: AppTheme.gold,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.white.withOpacity(0.08),
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

  Widget _buildUnifiedHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Altın Cüzdan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.8,
              ),
            ),
            const Gap(4),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4ADE80),
                    shape: BoxShape.circle,
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scaleXY(begin: 0.8, end: 1.3, duration: 1.seconds)
                .fadeIn(duration: 1.seconds),
                const Gap(6),
                Text(
                  'Canlı Piyasa Kurları',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
          icon: const Icon(Iconsax.user, color: Colors.white70, size: 22),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.03),
            padding: const EdgeInsets.all(8),
            shape: const CircleBorder(),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildPromoCard(BuildContext context) {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ÜCRETSİZ',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              const Gap(8),
              const Text(
                'Portföyünüzü Yönetin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.5,
                ),
              ),
              const Gap(4),
              Text(
                'Varlıklarınızı ekleyerek kar zarar durumunuzu anlık takip edin.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const Gap(16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.gold, width: 1.0),
                    foregroundColor: AppTheme.gold,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Text(
                    'Kayıt Ol',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
  double get minExtent => _tabBar.preferredSize.height + 16;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 16;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
