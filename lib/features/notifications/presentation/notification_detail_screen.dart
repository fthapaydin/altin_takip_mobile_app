import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/notifications/domain/notification.dart'
    as domain;
import 'package:altin_takip/features/dashboard/presentation/widgets/portfolio_chart.dart';
import 'package:altin_takip/features/dashboard/domain/dashboard_models.dart';
import 'package:shimmer/shimmer.dart';

class NotificationDetailScreen extends StatelessWidget {
  final domain.Notification notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final data = notification.data;
    final chartDataPoints = _getChartDataPoints(data);
    final changePercentage = data?.changePercentage ?? 0.0;
    final isPositive = changePercentage >= 0;

    final assets = data?.assets;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: data == null
                  ? _buildSkeleton(context)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Chart Section (if data available)
                          if (chartDataPoints.isNotEmpty) ...[
                            const Text(
                              'PERFORMANS ANALİZİ',
                              style: TextStyle(
                                color: AppTheme.gold,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Gap(16),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color:
                                    Colors.black, // Darker background for chart
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.05),
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Stats Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'PORTFÖY DEĞERİ',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.5,
                                              ),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Gap(4),
                                          Text(
                                            '₺${NumberFormat('#,##0.00', 'tr_TR').format(data.currentValue ?? 0)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              (isPositive
                                                      ? Colors.green
                                                      : Colors.red)
                                                  .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${isPositive ? '+' : ''}${NumberFormat('#,##0.00', 'tr_TR').format(data.changeAmount ?? 0)}',
                                              style: TextStyle(
                                                color: isPositive
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const Gap(8),
                                            Text(
                                              '(%${changePercentage.toStringAsFixed(2)})',
                                              style: TextStyle(
                                                color: isPositive
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(24),
                                  SizedBox(
                                    height: 200,
                                    child: PortfolioChart(
                                      chartData: chartDataPoints,
                                      // We can optionally calculate total cost if data provided,
                                      // but for now we'll just show the value curve.
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const Gap(24),

                          // Assets List (if available)
                          if (assets != null && assets.isNotEmpty) ...[
                            const Text(
                              'VARLIK DETAYLARI',
                              style: TextStyle(
                                color: AppTheme.gold,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Gap(16),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _groupAssets(assets).length,
                              separatorBuilder: (_, __) => const Gap(12),
                              itemBuilder: (context, index) {
                                final asset = _groupAssets(assets)[index];
                                final isAssetPositive =
                                    asset.changePercentage >= 0;

                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.05),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Icon or Fallback
                                      Container(
                                        width: 40,
                                        height: 40,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.05),
                                          shape: BoxShape.circle,
                                        ),
                                        // For now using generic icon, can implement network image if needed
                                        // or specific icon based on currency code
                                        child: const Icon(
                                          Iconsax.coin,
                                          color: AppTheme.gold,
                                          size: 20,
                                        ),
                                      ),
                                      const Gap(12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              asset.currencyName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              '${asset.amount % 1 == 0 ? asset.amount.toInt() : asset.amount} Adet',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.5,
                                                ),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '₺${NumberFormat('#,##0.00', 'tr_TR').format(asset.currentValue)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${isAssetPositive ? '+' : ''}${NumberFormat('#,##0.00', 'tr_TR').format(asset.changeAmount)} ₺',
                                                style: TextStyle(
                                                  color: isAssetPositive
                                                      ? Colors.green
                                                      : Colors.red,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const Gap(4),
                                              Text(
                                                '(${isAssetPositive ? '+' : ''}%${asset.changePercentage.toStringAsFixed(2)})',
                                                style: TextStyle(
                                                  color: isAssetPositive
                                                      ? Colors.green
                                                      : Colors.red,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Shimmer.fromColors(
            baseColor: Colors.white.withOpacity(0.05),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Container(
              width: 120,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const Gap(16),
          // Chart Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.05),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Column(
                children: [
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
                          const Gap(8),
                          Container(
                            width: 120,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 80,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(24),
          // Asset Title
          Shimmer.fromColors(
            baseColor: Colors.white.withOpacity(0.05),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Container(
              width: 120,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const Gap(16),
          // Asset List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, __) => const Gap(12),
            itemBuilder: (_, __) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.white.withOpacity(0.05),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const Gap(4),
                          Container(
                            width: 60,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 80,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Gap(4),
                        Container(
                          width: 60,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.glassColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Text(
            'Bildirim Detayı',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          // Placeholder for visual balance
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  List<ChartDataPoint> _getChartDataPoints(domain.NotificationData? data) {
    if (data?.chartData == null) return [];

    final labels = data!.chartData!.labels;
    final values = data.chartData!.values;

    if (labels.length != values.length) return [];

    final now = DateTime.now();

    return List.generate(values.length, (index) {
      final label = labels[index];
      DateTime date = now.subtract(Duration(hours: values.length - 1 - index));

      // Attempt basic parsing for better tooltip dates
      // Format 1: HH:mm (e.g. 00:00)
      if (label.contains(':')) {
        try {
          final parts = label.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          date = DateTime(now.year, now.month, now.day, hour, minute);
        } catch (_) {}
      }
      // Format 2: dd MMM (e.g. 02 Feb)
      else {
        try {
          // Simple parsing if locale matches or standard format
          // This is a "best effort" since "Feb" might be localized
        } catch (_) {}
      }

      return ChartDataPoint(date: date, value: values[index], label: label);
    });
  }

  List<domain.NotificationAsset> _groupAssets(
    List<domain.NotificationAsset> assets,
  ) {
    final Map<String, domain.NotificationAsset> groups = {};

    for (final asset in assets) {
      if (groups.containsKey(asset.currencyCode)) {
        final current = groups[asset.currencyCode]!;
        final totalStartValue = current.startValue + asset.startValue;
        final totalCurrentValue = current.currentValue + asset.currentValue;

        // Calculate new change percentage based on totals
        // Avoid division by zero
        final newChangePercentage = totalStartValue != 0
            ? ((totalCurrentValue - totalStartValue) / totalStartValue) * 100
            : 0.0;

        groups[asset.currencyCode] = domain.NotificationAsset(
          amount: current.amount + asset.amount,
          iconUrl: current.iconUrl,
          startPrice: current
              .startPrice, // Keep original or average? Original implies price per unit, but aggregated it might vary. We display total value mostly.
          startValue: totalStartValue,
          changeAmount: current.changeAmount + asset.changeAmount,
          currencyCode: current.currencyCode,
          currencyName: current.currencyName,
          currentPrice: current.currentPrice,
          currentValue: totalCurrentValue,
          changePercentage: newChangePercentage,
        );
      } else {
        groups[asset.currencyCode] = asset;
      }
    }

    return groups.values.toList();
  }
}
