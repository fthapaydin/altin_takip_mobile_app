import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altin_takip/features/notifications/presentation/notifications_screen.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/auth/presentation/auth_state.dart';
import 'package:altin_takip/features/assets/presentation/asset_notifier.dart';
import 'package:altin_takip/features/assets/presentation/asset_state.dart';
import 'package:iconsax/iconsax.dart';

class DashboardHeader extends StatelessWidget {
  final AuthState authState;

  const DashboardHeader({super.key, required this.authState});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ── Date Only ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portföyüm',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    letterSpacing: -0.5,
                  ),
                ),
                const Gap(2),
                Text(
                  DateFormat('d MMMM yyyy', 'tr_TR').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 13,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),

            // ── Action Buttons ──
            Row(
              children: [_NotificationButton(), const Gap(4), _RefreshButton()],
            ),
          ],
        ),
        const Gap(8),
        _LoadingIndicator(),
      ],
    ).animate().fadeIn().slideX();
  }
}

// ─────────────────────────────────────────────

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        );
      },
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.gold, AppTheme.gold.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.gold.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Iconsax.notification, size: 20, color: Colors.black),
      ),
    ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack);
  }
}

class _RefreshButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetState = ref.watch(assetProvider);
    final isLoading = assetState is AssetLoaded && assetState.isRefreshing;

    return IconButton(
      onPressed: () =>
          ref.read(assetProvider.notifier).loadDashboard(refresh: true),
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
    );
  }
}

class _LoadingIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetState = ref.watch(assetProvider);
    final isLoading = assetState is AssetLoaded && assetState.isRefreshing;

    return AnimatedOpacity(
      opacity: isLoading ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: LinearProgressIndicator(
        backgroundColor: Colors.transparent,
        color: AppTheme.gold.withOpacity(0.3),
        minHeight: 2,
      ),
    );
  }
}
