import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/notifications/domain/notification.dart' as domain;
import 'package:altin_takip/features/dashboard/domain/dashboard_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/features/notifications/presentation/notifications_notifier.dart';
import 'package:altin_takip/core/widgets/app_bar_widget.dart';
import 'package:altin_takip/features/notifications/presentation/widgets/notification_detail_skeleton.dart';
import 'package:altin_takip/features/notifications/presentation/widgets/notification_performance_chart.dart';
import 'package:altin_takip/features/notifications/presentation/widgets/notification_assets_list.dart';

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
                  ? const NotificationDetailSkeleton()
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
                          if (chartDataPoints.isNotEmpty) ...[
                            NotificationPerformanceChart(
                              chartDataPoints: chartDataPoints,
                              currentValue: data.currentValue ?? 0.0,
                              changeAmount: data.changeAmount ?? 0.0,
                              changePercentage: changePercentage,
                            ),
                            const Gap(24),
                          ],
                          if (assets != null && assets.isNotEmpty) ...[
                            NotificationAssetsList(assets: assets),
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

  List<ChartDataPoint> _getChartDataPoints(domain.NotificationData? data) {
    if (data?.chartData == null) return [];

    final labels = data!.chartData!.labels;
    final values = data.chartData!.values;

    if (labels.length != values.length) return [];

    final now = DateTime.now();

    return List.generate(values.length, (index) {
      final label = labels[index];
      DateTime date = now.subtract(Duration(hours: values.length - 1 - index));

      if (label.contains(':')) {
        try {
          final parts = label.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          date = DateTime(now.year, now.month, now.day, hour, minute);
        } catch (_) {}
      }

      return ChartDataPoint(date: date, value: values[index], label: label);
    });
  }
}
