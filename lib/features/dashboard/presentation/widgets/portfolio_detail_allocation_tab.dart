import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/portfolio_detail_models.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/portfolio_detail_allocation_strip.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/portfolio_detail_allocation_detail_card.dart';

/// Tab content for Asset Allocation (Gold vs Forex strips and numbers).
class PortfolioDetailAllocationTab extends StatelessWidget {
  final PortfolioAllocationData allocation;

  const PortfolioDetailAllocationTab({super.key, required this.allocation});

  @override
  Widget build(BuildContext context) {
    if (allocation.total == 0) {
      return const Center(
        child: Text(
          'Henüz varlık yok',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      children: [
        PortfolioDetailAllocationStrip(allocation: allocation),
        const Gap(16),
        PortfolioDetailAllocationDetailCard(allocation: allocation),
      ],
    );
  }
}
