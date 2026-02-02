import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/notifications/presentation/notifications_notifier.dart';
import 'package:altin_takip/features/notifications/presentation/notification_state.dart';
import 'package:altin_takip/features/notifications/domain/notification.dart'
    as domain;
import 'package:altin_takip/features/notifications/presentation/notification_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

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
      // Only load if not already loaded or if specifically needed
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isLoading),
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isLoading) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                  const Gap(16),
                  const Text(
                    'Bildirimler',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => ref
                    .read(notificationsProvider.notifier)
                    .loadNotifications(refresh: true),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLoading ? Iconsax.timer_1 : Iconsax.refresh,
                    size: 20,
                    color: isLoading ? AppTheme.gold : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedOpacity(
          opacity: isLoading ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            color: AppTheme.gold.withOpacity(0.3),
            minHeight: 2,
          ),
        ),
      ],
    ).animate().fadeIn().slideX();
  }

  Widget _buildBody(NotificationState state) {
    // Handling initial loading state
    if (state is NotificationInitial) {
      return _buildShimmerList();
    }

    // Attempt to extract existing notifications from any state that might have them
    List<domain.Notification>? currentData;
    if (state is NotificationLoaded) {
      currentData = state.notifications;
    } else if (state is NotificationLoading) {
      currentData = state.currentNotifications;
    } else if (state is NotificationError) {
      currentData = state.currentNotifications;
    }

    // If we have no data at all and we are loading, show shimmer
    if (state is NotificationLoading &&
        (currentData == null || currentData.isEmpty)) {
      return _buildShimmerList();
    }

    // If error and no data, show error screen
    if (state is NotificationError &&
        (currentData == null || currentData.isEmpty)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.danger, size: 48, color: Colors.red.withOpacity(0.5)),
            const Gap(16),
            Text(
              state.message,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
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

    // If we have data (or empty list after load), show it
    final notifications = currentData ?? [];

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.notification_bing,
                size: 48,
                color: AppTheme.gold.withOpacity(0.5),
              ),
            ),
            const Gap(24),
            Text(
              'Henüz bildiriminiz yok',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
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
        padding: const EdgeInsets.all(24),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(domain.Notification notification) {
    final isRead = notification.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRead ? Colors.transparent : AppTheme.gold.withOpacity(0.3),
        ),
        boxShadow: [
          if (!isRead)
            BoxShadow(
              color: AppTheme.gold.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref
                .read(notificationsProvider.notifier)
                .markAsRead(notification.id);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NotificationDetailScreen(notification: notification),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.chart_2,
                    color: AppTheme.gold,
                    size: 24,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isRead
                                    ? FontWeight.w600
                                    : FontWeight.w800,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.gold,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const Gap(8),
                      Text(
                        notification.body,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(12),
                      Row(
                        children: [
                          Icon(
                            Iconsax.clock,
                            size: 14,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const Gap(6),
                          Text(
                            DateFormat(
                              'd MMMM, HH:mm',
                              'tr_TR',
                            ).format(notification.createdAt),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 8,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Shimmer.fromColors(
          baseColor: AppTheme.surface,
          highlightColor: AppTheme.surface.withOpacity(0.5),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const Gap(8),
                      Container(
                        width: 200,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const Gap(12),
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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
