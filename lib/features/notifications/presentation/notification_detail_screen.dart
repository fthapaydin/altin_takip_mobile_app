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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/features/notifications/presentation/notifications_notifier.dart';
import 'package:altin_takip/core/widgets/app_bar_widget.dart';

class NotificationDetailScreen extends ConsumerStatefulWidget {
  final domain.Notification notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  ConsumerState<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends ConsumerState<NotificationDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Api çağrısı ile bildirimi okundu olarak işaretle
    if (widget.notification.readAt == null) {
      Future.microtask(() {
        ref
            .read(notificationsProvider.notifier)
            .markAsRead(widget.notification.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.notification.data;
    final chartDataPoints = _getChartDataPoints(data);
    final changePercentage = data?.changePercentage ?? 0.0;
    final isPositive = changePercentage >= 0;

    final assets = data?.assets;

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: const AppBarWidget(
        title: 'Bildirim Detayı',
        isLargeTitle: false,
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: data == null
                  ? _buildSkeleton(context)
                  : SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        MediaQuery.of(context).padding.top + AppBarWidget.getExpandedHeight(isLargeTitle: false) + 12.0,
                        24,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Chart Section (if data available)
                          if (chartDataPoints.isNotEmpty) ...[
                            Text(
                              'PERFORMANS ANALİZİ',
                              style: TextStyle(
                                color: AppTheme.gold.withValues(alpha: 0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const Gap(16),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0F1116), Color(0xFF09090A)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  width: 1,
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
                                              color: Colors.white.withValues(alpha: 0.4),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const Gap(4),
                                          Text(
                                            '₺${NumberFormat('#,##0.00', 'tr_TR').format(data.currentValue ?? 0)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w500,
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
                                          color: (isPositive
                                                  ? const Color(0xFF10B981)
                                                  : const Color(0xFFEF4444))
                                              .withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: (isPositive
                                                    ? const Color(0xFF10B981)
                                                    : const Color(0xFFEF4444))
                                                .withValues(alpha: 0.15),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${isPositive ? '+' : ''}${NumberFormat('#,##0.00', 'tr_TR').format(data.changeAmount ?? 0)}',
                                              style: TextStyle(
                                                color: isPositive
                                                    ? const Color(0xFF10B981)
                                                    : const Color(0xFFEF4444),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const Gap(6),
                                            Text(
                                              '(%${changePercentage.toStringAsFixed(2)})',
                                              style: TextStyle(
                                                color: isPositive
                                                    ? const Color(0xFF10B981)
                                                    : const Color(0xFFEF4444),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
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
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const Gap(24),

                          // Assets List (if available)
                          if (assets != null && assets.isNotEmpty) ...[
                            Text(
                              'VARLIK DETAYLARI',
                              style: TextStyle(
                                color: AppTheme.gold.withValues(alpha: 0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const Gap(16),
                            ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _groupAssets(assets).length,
                              separatorBuilder: (_, __) => const Gap(12),
                              itemBuilder: (context, index) {
                                final asset = _groupAssets(assets)[index];
                                final isAssetPositive =
                                    asset.changePercentage >= 0;
                                final isGoldAsset = asset.currencyCode.toLowerCase().contains('altin') ||
                                    asset.currencyCode.toLowerCase().contains('xau') ||
                                    asset.currencyName.toLowerCase().contains('altin') ||
                                    asset.currencyName.toLowerCase().contains('gold');
                                final themeColor = isGoldAsset ? AppTheme.gold : const Color(0xFF4C82F7);

                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.02),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Dynamic Category Avatar Container
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: themeColor.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: themeColor.withValues(alpha: 0.15),
                                            width: 1,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          isGoldAsset ? Iconsax.coin_1 : Iconsax.dollar_circle,
                                          color: themeColor,
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
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const Gap(2),
                                            Text(
                                              '${asset.amount % 1 == 0 ? asset.amount.toInt() : asset.amount} Adet',
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.45),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w400,
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
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const Gap(2),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${isAssetPositive ? '+' : ''}${NumberFormat('#,##0.00', 'tr_TR').format(asset.changeAmount)} ₺',
                                                style: TextStyle(
                                                  color: isAssetPositive
                                                      ? const Color(0xFF10B981)
                                                      : const Color(0xFFEF4444),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const Gap(4),
                                              Text(
                                                '(${isAssetPositive ? '+' : ''}%${asset.changePercentage.toStringAsFixed(2)})',
                                                style: TextStyle(
                                                  color: isAssetPositive
                                                      ? const Color(0xFF10B981)
                                                      : const Color(0xFFEF4444),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w400,
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
            baseColor: Colors.white.withValues(alpha: 0.05),
            highlightColor: Colors.white.withValues(alpha: 0.1),
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
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.white.withValues(alpha: 0.05),
              highlightColor: Colors.white.withValues(alpha: 0.1),
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
            baseColor: Colors.white.withValues(alpha: 0.05),
            highlightColor: Colors.white.withValues(alpha: 0.1),
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
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.white.withValues(alpha: 0.05),
                highlightColor: Colors.white.withValues(alpha: 0.1),
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
