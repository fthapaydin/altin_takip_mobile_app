import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/features/dashboard/domain/dashboard_models.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/portfolio_detail_chart_widget.dart';
import 'package:altin_takip/features/dashboard/presentation/widgets/portfolio_detail_change_list.dart';

/// Tab content for daily value changes (Chart + Change List).
class PortfolioDetailChangeTab extends StatelessWidget {
  final List<ChartDataPoint> chartData;

  const PortfolioDetailChangeTab({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    if (chartData.length < 2) {
      return const Center(
        child: Text(
          'Henüz yeterli veri yok',
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
        PortfolioDetailChartWidget(chartData: chartData),
        const Gap(12),
        PortfolioDetailChangeList(chartData: chartData),
      ],
    );
  }
}
