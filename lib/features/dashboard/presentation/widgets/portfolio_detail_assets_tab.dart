import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/portfolio_detail_models.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/portfolio_detail_asset_row.dart';

/// Tab content displaying the list of all assets in the portfolio.
class PortfolioDetailAssetsTab extends StatelessWidget {
  final List<PortfolioBreakdownItem> breakdown;

  const PortfolioDetailAssetsTab({super.key, required this.breakdown});

  @override
  Widget build(BuildContext context) {
    if (breakdown.isEmpty) {
      return const Center(child: _EmptyState());
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      itemCount: breakdown.length,
      separatorBuilder: (_, __) => const Gap(8),
      itemBuilder: (context, index) => PortfolioDetailAssetRow(
        item: breakdown[index],
        index: index,
        maxValue: breakdown.first.value,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
