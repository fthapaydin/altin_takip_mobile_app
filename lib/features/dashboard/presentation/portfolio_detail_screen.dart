import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/widgets/app_bar_widget.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:altin_takip/features/settings/presentation/preference_notifier.dart';

/// Full-page portfolio breakdown screen.
/// Shows allocation bar, asset breakdown list, and summary stats.
class PortfolioDetailScreen extends ConsumerWidget {
  final AssetLoaded state;

  const PortfolioDetailScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacy = ref.watch(preferenceProvider).isPrivacyModeEnabled;
    final breakdown = _computeBreakdown(state);
    final allocation = _computeAllocation(state);
    final dashboardSummary = state.dashboardData?.summary;

    final totalWorth = dashboardSummary?.totalValue ?? _totalWorth(state);
    final profitLoss = dashboardSummary?.profitLoss ?? _profitLoss(state);
    final totalCost = dashboardSummary?.totalCost ?? (totalWorth - profitLoss);
    final profitPercentage =
        dashboardSummary?.profitLossPercentage ??
        (totalCost > 0 ? (profitLoss / totalCost) * 100 : 0.0);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const AppBarWidget(
        title: 'Portföy Detayları',
        showBack: true,
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: _PrivacyBlur(
          enabled: isPrivacy,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              // ── Hero balance card ──
              _HeroBalanceCard(
                totalWorth: totalWorth,
                totalCost: totalCost,
                profitLoss: profitLoss,
                profitPercentage: profitPercentage,
              ),
              const Gap(24),

              // ── Allocation section ──
              if (allocation.total > 0) ...[
                _SectionLabel(
                  icon: Iconsax.diagram,
                  label: 'DAĞILIM',
                ),
                const Gap(12),
                _AllocationStrip(allocation: allocation),
                const Gap(24),
              ],

              // ── Asset breakdown ──
              if (breakdown.isNotEmpty) ...[
                _SectionLabel(
                  icon: Iconsax.coin_1,
                  label: 'VARLIKLAR',
                  trailing: '${breakdown.length} adet',
                ),
                const Gap(12),
                ...breakdown.asMap().entries.map((entry) {
                  return _AssetRow(
                    item: entry.value,
                    index: entry.key,
                    maxValue: breakdown.first.value,
                  );
                }),
              ],

              if (breakdown.isEmpty)
                _EmptyState(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Calculations ──

  double _totalWorth(AssetLoaded state) {
    if (state.assets.isEmpty || state.currencies.isEmpty) return 0.0;
    double total = 0;
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
        total += amount * currency.selling;
      } catch (_) {}
    });
    return total;
  }

  double _profitLoss(AssetLoaded state) {
    double totalCost = 0;
    double currentVal = 0;
    for (var asset in state.assets) {
      if (asset.type == 'buy') {
        totalCost += asset.amount * asset.price;
        currentVal += asset.amount * (asset.currency?.selling ?? asset.price);
      } else {
        totalCost -= asset.amount * asset.price;
        currentVal -= asset.amount * (asset.currency?.buying ?? asset.price);
      }
    }
    return currentVal - totalCost;
  }

  _AllocationData _computeAllocation(AssetLoaded state) {
    double goldValue = 0;
    double forexValue = 0;
    final Map<int, double> holdings = {};

    for (var asset in state.assets) {
      if (asset.type == 'buy') {
        holdings[asset.currencyId] = (holdings[asset.currencyId] ?? 0) + asset.amount;
      } else {
        holdings[asset.currencyId] = (holdings[asset.currencyId] ?? 0) - asset.amount;
      }
    }

    holdings.forEach((currencyId, amount) {
      if (amount <= 0) return;
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
    return _AllocationData(
      goldValue: goldValue,
      forexValue: forexValue,
      total: total,
      goldPercent: total > 0 ? goldValue / total * 100 : 0,
      forexPercent: total > 0 ? forexValue / total * 100 : 0,
    );
  }

  List<_BreakdownItem> _computeBreakdown(AssetLoaded state) {
    final Map<int, double> holdings = {};
    for (var asset in state.assets) {
      if (asset.type == 'buy') {
        holdings[asset.currencyId] = (holdings[asset.currencyId] ?? 0) + asset.amount;
      } else {
        holdings[asset.currencyId] = (holdings[asset.currencyId] ?? 0) - asset.amount;
      }
    }

    double totalValue = 0;
    final items = <_BreakdownItem>[];

    const goldColors = [
      Color(0xFFE5C07B),
      Color(0xFFF0D28C),
      Color(0xFFC49B55),
      Color(0xFFD4A855),
    ];
    const forexColors = [
      Color(0xFF60A5FA),
      Color(0xFF818CF8),
      Color(0xFF34D399),
      Color(0xFF22D3EE),
    ];

    int goldIdx = 0;
    int forexIdx = 0;

    holdings.forEach((currencyId, amount) {
      if (amount <= 0) return;
      final currency = state.currencies.firstWhere(
        (c) => c.id == currencyId,
        orElse: () => state.currencies.first,
      );
      final value = amount * currency.selling;
      totalValue += value;

      final isGold = currency.type == 'Altın';
      final color = isGold
          ? goldColors[goldIdx++ % goldColors.length]
          : forexColors[forexIdx++ % forexColors.length];

      items.add(_BreakdownItem(
        name: currency.name,
        value: value,
        percentage: 0,
        color: color,
        type: currency.type,
        amount: amount,
      ));
    });

    if (totalValue == 0) return [];

    final result = items.map((item) {
      return _BreakdownItem(
        name: item.name,
        value: item.value,
        percentage: (item.value / totalValue) * 100,
        color: item.color,
        type: item.type,
        amount: item.amount,
      );
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return result;
  }
}

// ─────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────

class _AllocationData {
  final double goldValue;
  final double forexValue;
  final double total;
  final double goldPercent;
  final double forexPercent;

  const _AllocationData({
    required this.goldValue,
    required this.forexValue,
    required this.total,
    required this.goldPercent,
    required this.forexPercent,
  });
}

class _BreakdownItem {
  final String name;
  final double value;
  final double percentage;
  final Color color;
  final String type;
  final double amount;

  const _BreakdownItem({
    required this.name,
    required this.value,
    required this.percentage,
    required this.color,
    required this.type,
    required this.amount,
  });
}

// ─────────────────────────────────────────────
// Hero Balance Card
// ─────────────────────────────────────────────

class _HeroBalanceCard extends StatelessWidget {
  final double totalWorth;
  final double totalCost;
  final double profitLoss;
  final double profitPercentage;

  const _HeroBalanceCard({
    required this.totalWorth,
    required this.totalCost,
    required this.profitLoss,
    required this.profitPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = profitLoss >= 0;
    final profitColor = isPositive
        ? const Color(0xFF34D399)
        : const Color(0xFFEF4444);
    final formatter = NumberFormat('#,##0.00', 'tr_TR');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.surface,
            AppTheme.surface.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          // Balance
          Text(
            '₺${formatter.format(totalWorth)}',
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w400,
              letterSpacing: -1.5,
            ),
          ),
          const Gap(12),

          // Stats row
          Row(
            children: [
              _HeroStat(
                label: 'Yatırım',
                value: '₺${formatter.format(totalCost)}',
                color: AppTheme.gold,
              ),
              _VerticalDivider(),
              _HeroStat(
                label: 'Kâr / Zarar',
                value:
                    '${isPositive ? '+' : '-'}₺${formatter.format(profitLoss.abs())}',
                color: profitColor,
              ),
              _VerticalDivider(),
              _HeroStat(
                label: 'Getiri',
                value:
                    '${isPositive ? '+' : ''}%${NumberFormat('#,##0.1', 'tr_TR').format(profitPercentage)}',
                color: profitColor,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HeroStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
          const Gap(4),
          Text(
            value,
            style: TextStyle(
              fontFeatures: const [FontFeature.tabularFigures()],
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white.withValues(alpha: 0.08),
    );
  }
}

// ─────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;

  const _SectionLabel({
    required this.icon,
    required this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.35)),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.25),
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Allocation strip (Gold vs Forex)
// ─────────────────────────────────────────────

class _AllocationStrip extends StatelessWidget {
  final _AllocationData allocation;

  const _AllocationStrip({required this.allocation});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00', 'tr_TR');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          // Progress bar
          SizedBox(
            height: 8,
            child: Row(
              children: [
                if (allocation.goldValue > 0)
                  Expanded(
                    flex: allocation.goldPercent.round().clamp(1, 100),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                if (allocation.goldValue > 0 && allocation.forexValue > 0)
                  const Gap(4),
                if (allocation.forexValue > 0)
                  Expanded(
                    flex: allocation.forexPercent.round().clamp(1, 100),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF60A5FA),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Gap(16),
          // Labels
          Row(
            children: [
              Expanded(
                child: _AllocationLabel(
                  label: 'Altın',
                  value: '₺${formatter.format(allocation.goldValue)}',
                  percentage: '%${allocation.goldPercent.toStringAsFixed(0)}',
                  color: AppTheme.gold,
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              Expanded(
                child: _AllocationLabel(
                  label: 'Döviz',
                  value: '₺${formatter.format(allocation.forexValue)}',
                  percentage: '%${allocation.forexPercent.toStringAsFixed(0)}',
                  color: const Color(0xFF60A5FA),
                  isRight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }
}

class _AllocationLabel extends StatelessWidget {
  final String label;
  final String value;
  final String percentage;
  final Color color;
  final bool isRight;

  const _AllocationLabel({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
    this.isRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isRight ? 20 : 0,
        right: isRight ? 0 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Gap(6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                percentage,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Asset row
// ─────────────────────────────────────────────

class _AssetRow extends StatelessWidget {
  final _BreakdownItem item;
  final int index;
  final double maxValue;

  const _AssetRow({
    required this.item,
    required this.index,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final barFraction = maxValue > 0 ? item.value / maxValue : 0.0;
    final formatter = NumberFormat('#,##0.00', 'tr_TR');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Color dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: item.color.withValues(alpha: 0.35),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                // Name + type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(2),
                      Text(
                        item.type,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Value + percentage
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₺${formatter.format(item.value)}',
                      style: const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()],
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Gap(2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '%${item.percentage.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: item.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(10),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                height: 3,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          width: constraints.maxWidth,
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          width: constraints.maxWidth * barFraction,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                item.color.withValues(alpha: 0.6),
                                item.color,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: 150 + (index * 50)),
      duration: 350.ms,
    ).slideX(begin: 0.03, end: 0, curve: Curves.easeOutCubic);
  }
}

// ─────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.wallet_money,
              color: AppTheme.gold.withValues(alpha: 0.6),
              size: 32,
            ),
          ),
          const Gap(16),
          const Text(
            'Henüz Varlık Yok',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          const Gap(8),
          Text(
            'Varlık eklediğinizde portföy dağılımınız\nburada görüntülenecek.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Privacy blur wrapper
// ─────────────────────────────────────────────

class _PrivacyBlur extends ConsumerWidget {
  final bool enabled;
  final Widget child;

  const _PrivacyBlur({required this.enabled, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!enabled) return child;
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 6.6, sigmaY: 6.6),
      child: AbsorbPointer(child: child),
    );
  }
}
