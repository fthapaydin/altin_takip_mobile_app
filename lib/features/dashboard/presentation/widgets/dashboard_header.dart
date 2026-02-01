import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altin_takip/features/chat/presentation/chat_list_screen.dart';
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
    final user = (authState is AuthAuthenticated)
        ? (authState as AuthAuthenticated).user
        : null;
    final isEncrypted = user?.isEncrypted ?? false;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Merhaba, ${user?.formattedName ?? "Misafir"}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                    if (isEncrypted) ...[
                      const Gap(8),
                      const Icon(
                        Iconsax.security_safe,
                        color: AppTheme.gold,
                        size: 18,
                      ),
                    ],
                  ],
                ),
                Text(
                  DateFormat('d MMMM yyyy', 'tr_TR').format(DateTime.now()),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatListScreen()),
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
                    child: const Icon(
                      Iconsax.magic_star,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack),
                Consumer(
                  builder: (context, ref, _) {
                    final assetState = ref.watch(assetProvider);
                    final isLoading =
                        assetState is AssetLoaded && assetState.isRefreshing;

                    return IconButton(
                      onPressed: () => ref
                          .read(assetProvider.notifier)
                          .loadDashboard(refresh: true),
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
                  },
                ),
              ],
            ),
          ],
        ),
        const Gap(8),
        Consumer(
          builder: (context, ref, _) {
            final assetState = ref.watch(assetProvider);
            final isLoading =
                assetState is AssetLoaded && assetState.isRefreshing;

            return AnimatedOpacity(
              opacity: isLoading ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: AppTheme.gold.withOpacity(0.3),
                minHeight: 2,
              ),
            );
          },
        ),
      ],
    ).animate().fadeIn().slideX();
  }
}
