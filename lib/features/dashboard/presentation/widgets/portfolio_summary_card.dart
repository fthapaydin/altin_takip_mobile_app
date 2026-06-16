import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/features/settings/presentation/preference_notifier.dart';
import 'package:altin_takip/features/dashboard/presentation/portfolio_detail_screen.dart';
import 'package:iconsax/iconsax.dart';

class PortfolioSummaryCard extends ConsumerWidget {
  final AssetState state;

  const PortfolioSummaryCard({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacyMode = ref.watch(preferenceProvider).isPrivacyModeEnabled;

    if (state is AssetLoading) {
      return const _PortfolioShimmer();
    }

    final dashboardSummary = (state is AssetLoaded)
        ? (state as AssetLoaded).dashboardData?.summary
        : null;

    final totalWorth =
        dashboardSummary?.totalValue ??
        (state is AssetLoaded
            ? _calculateTotalWorth(state as AssetLoaded)
            : 0.0);
    final profitLoss =
        dashboardSummary?.profitLoss ??
        (state is AssetLoaded
            ? _calculateProfitLoss(state as AssetLoaded)
            : 0.0);
    final totalCost = dashboardSummary?.totalCost ?? (totalWorth - profitLoss);
    final profitPercentage =
        dashboardSummary?.profitLossPercentage ??
        (totalCost > 0 ? (profitLoss / totalCost) * 100 : 0.0);

    return GestureDetector(
      onTap: () {
        if (state is AssetLoaded) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PortfolioDetailScreen(state: state as AssetLoaded),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(0, 16),
              blurRadius: 32,
              spreadRadius: -8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Subtle ambient glow
              Positioned(
                top: -40,
                right: -40,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.gold.withValues(alpha: 0.12),
                    ),
                  ),
                ),
              ),

              // Main Content
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: _buildPrivacyBlur(
                  enabled: isPrivacyMode,
                  child: AbsorbPointer(
                    absorbing: isPrivacyMode,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Balance Row ──
                        _BalanceRow(
                          totalWorth: totalWorth,
                          profitLoss: profitLoss,
                          profitPercentage: profitPercentage,
                        ),
                        const Gap(20),

                        // ── Stat Tiles ──
                        _StatRow(
                          totalCost: totalCost,
                          profitLoss: profitLoss,
                        ),
                        const Gap(16),

                        // ── "Detayları Gör" CTA ──
                        const _DetailsCta(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08, end: 0);
  }

  Widget _buildPrivacyBlur({
    required Widget child,
    required bool enabled,
    double sigma = 6.6,
  }) {
    if (!enabled) return child;
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: child,
    );
  }

  double _calculateTotalWorth(AssetLoaded state) {
    if (state.assets.isEmpty || state.currencies.isEmpty) return 0.0;

    double currentTotalValue = 0;
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
      try {
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
      } catch (_) {}
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
}

// ─────────────────────────────────────────────
// Balance row: value + profit pill
// ─────────────────────────────────────────────

class _BalanceRow extends StatelessWidget {
  final double totalWorth;
  final double profitLoss;
  final double profitPercentage;

  const _BalanceRow({
    required this.totalWorth,
    required this.profitLoss,
    required this.profitPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = profitLoss >= 0;
    final pillColor = isPositive
        ? const Color(0xFF34D399)
        : const Color(0xFFEF4444);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOPLAM VARLIK',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
              const Gap(6),
              Text(
                '₺${NumberFormat('#,##0.00', 'tr_TR').format(totalWorth)}',
                style: const TextStyle(
                  fontFeatures: [FontFeature.tabularFigures()],
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: pillColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: pillColor.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPositive ? Iconsax.arrow_up : Iconsax.arrow_down,
                color: pillColor,
                size: 12,
              ),
              const Gap(3),
              Text(
                '%${NumberFormat('#,##0.1', 'tr_TR').format(profitPercentage.abs())}',
                style: TextStyle(
                  color: pillColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Stat row: investment + profit/loss
// ─────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final double totalCost;
  final double profitLoss;

  const _StatRow({
    required this.totalCost,
    required this.profitLoss,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = profitLoss >= 0;
    final profitColor = isPositive
        ? const Color(0xFF34D399)
        : const Color(0xFFEF4444);
    final formatter = NumberFormat('#,##0.00', 'tr_TR');

    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            icon: Iconsax.wallet_1,
            iconColor: AppTheme.gold,
            label: 'Yatırım',
            value: '₺${formatter.format(totalCost)}',
            valueColor: Colors.white,
          ),
        ),
        const Gap(8),
        Expanded(
          child: _MiniStat(
            icon: isPositive ? Iconsax.trend_up : Iconsax.trend_down,
            iconColor: profitColor,
            label: 'Kâr / Zarar',
            value:
                '${isPositive ? '+' : '-'}₺${formatter.format(profitLoss.abs())}',
            valueColor: profitColor,
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  const _MiniStat({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 26,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 10, color: iconColor.withValues(alpha: 0.7)),
                    const Gap(4),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 9,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const Gap(2),
                Text(
                  value,
                  style: TextStyle(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: valueColor,
                    fontSize: 13,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// "Detayları Gör" CTA row
// ─────────────────────────────────────────────

class _DetailsCta extends StatelessWidget {
  const _DetailsCta();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Portföy Detayları',
            style: TextStyle(
              color: AppTheme.gold.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const Gap(6),
          Icon(
            Iconsax.arrow_right_3,
            size: 14,
            color: AppTheme.gold.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shimmer / Loading state
// ─────────────────────────────────────────────

class _PortfolioShimmer extends StatelessWidget {
  const _PortfolioShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Shimmer.fromColors(
          baseColor: Colors.white.withValues(alpha: 0.05),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Gap(10),
                        Container(
                          width: 150,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 60,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ],
                ),
                const Gap(20),

                // Stat tiles
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(16),

                // CTA placeholder
                Container(
                  height: 16,
                  width: 100,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
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
