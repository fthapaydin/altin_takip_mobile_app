import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/notifications/presentation/notifications_notifier.dart';
import 'package:altin_takip/features/notifications/presentation/notification_state.dart';
import 'package:altin_takip/features/notifications/domain/notification.dart' as domain;
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/widgets/app_bar_widget.dart';
import 'package:altin_takip/features/notifications/presentation/widgets/notification_card.dart';
import 'package:altin_takip/features/notifications/presentation/widgets/notifications_list_shimmer.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(notificationsProvider);
      if (state is NotificationInitial) {
        ref
            .read(notificationsProvider.notifier)
            .loadNotifications(refresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final isLoading = state is NotificationLoading;

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBarWidget(
        title: 'Bildirimler',
        isLargeTitle: false,
        actions: [
          AppBarActionButton(
            icon: isLoading ? Iconsax.timer_1 : Iconsax.refresh,
            onTap: () => ref
                .read(notificationsProvider.notifier)
                .loadNotifications(refresh: true),
          ),
          const Gap(16),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Gap(MediaQuery.of(context).padding.top + AppBarWidget.getExpandedHeight(isLargeTitle: false) + 8.0),
            AnimatedOpacity(
              opacity: isLoading ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: AppTheme.gold.withValues(alpha: 0.3),
                minHeight: 2,
              ),
            ),
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(NotificationState state) {
    if (state is NotificationInitial) {
      return const NotificationsListShimmer();
    }

    List<domain.Notification>? currentData;
    if (state is NotificationLoaded) {
      currentData = state.notifications;
    } else if (state is NotificationLoading) {
      currentData = state.currentNotifications;
    } else if (state is NotificationError) {
      currentData = state.currentNotifications;
    }

    if (state is NotificationLoading &&
        (currentData == null || currentData.isEmpty)) {
      return const NotificationsListShimmer();
    }

    if (state is NotificationError &&
        (currentData == null || currentData.isEmpty)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.danger, size: 48, color: Colors.red.withValues(alpha: 0.5)),
            const Gap(16),
            Text(
              state.message,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(notificationsProvider.notifier)
                    .loadNotifications(refresh: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.black,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    final notifications = currentData ?? [];

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.notification_bing,
                size: 48,
                color: AppTheme.gold.withValues(alpha: 0.5),
              ),
            ),
            const Gap(24),
            Text(
              'Henüz bildiriminiz yok',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.gold,
      backgroundColor: AppTheme.surface,
      onRefresh: () => ref
          .read(notificationsProvider.notifier)
          .loadNotifications(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 80),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationCard(notification: notification);
        },
      ),
    );
  }
}
