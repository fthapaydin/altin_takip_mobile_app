import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/widgets/app_bar_widget.dart';
import 'package:altin_takip/core/widgets/privacy_blur.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/dashboard/domain/dashboard_models.dart';
import 'package:altin_takip/features/dashboard/presentation/helpers/portfolio_detail_helper.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/portfolio_hero_balance_card.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/portfolio_detail_change_tab.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/portfolio_detail_allocation_tab.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/portfolio_detail_assets_tab.dart';
import 'package:altin_takip/features/settings/presentation/preference_notifier.dart';

/// Full-page portfolio breakdown screen.
/// Shows allocation bar, asset breakdown list, daily chart and summary stats.
class PortfolioDetailScreen extends ConsumerWidget {
  final AssetLoaded state;

  const PortfolioDetailScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacy = ref.watch(preferenceProvider).isPrivacyModeEnabled;
    final breakdown = PortfolioDetailHelper.computeBreakdown(state);
    final allocation = PortfolioDetailHelper.computeAllocation(state);
    final dashboardSummary = state.dashboardData?.summary;

    final totalWorth = dashboardSummary?.totalValue ?? PortfolioDetailHelper.computeTotalWorth(state);
    final profitLoss = dashboardSummary?.profitLoss ?? PortfolioDetailHelper.computeProfitLoss(state);
    final totalCost = dashboardSummary?.totalCost ?? (totalWorth - profitLoss);
    final profitPercentage =
        dashboardSummary?.profitLossPercentage ??
        (totalCost > 0 ? (profitLoss / totalCost) * 100 : 0.0);

    final rawChartData = state.dashboardData?.chartData ?? [];
    final sortedChartData = List<ChartDataPoint>.from(rawChartData)
      ..sort((a, b) => a.date.compareTo(b.date));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: const AppBarWidget(
          title: 'Portföy Detayları',
          showBack: true,
          centerTitle: true,
        ),
        body: SafeArea(
          top: false,
          child: PrivacyBlur(
            enabled: isPrivacy,
            child: Column(
              children: [
                // ── Fixed Hero Card ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: PortfolioHeroBalanceCard(
                    totalWorth: totalWorth,
                    totalCost: totalCost,
                    profitLoss: profitLoss,
                    profitPercentage: profitPercentage,
                  ),
                ),
                const Gap(16),

                // ── Sticky Tab Bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.glassColor,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: AppTheme.glassBorder),
                    ),
                    child: TabBar(
                      isScrollable: false,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.white,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      indicator: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      overlayColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                      tabs: const [
                        Tab(text: 'Değişim'),
                        Tab(text: 'Dağılım'),
                        Tab(text: 'Varlıklar'),
                      ],
                    ),
                  ),
                ),
                const Gap(12),

                // ── Tab Content ──
                Expanded(
                  child: TabBarView(
                    children: [
                      PortfolioDetailChangeTab(chartData: sortedChartData),
                      PortfolioDetailAllocationTab(allocation: allocation),
                      PortfolioDetailAssetsTab(breakdown: breakdown),
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
}
