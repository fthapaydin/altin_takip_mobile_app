import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';

/// Shimmer loader skeleton for the Chat List screen.
class ChatListSkeleton extends StatelessWidget {
  const ChatListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: 5,
      separatorBuilder: (_, __) => const Gap(16),
      itemBuilder: (_, index) => Container(
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.surface,
              AppTheme.surface.withValues(alpha: 0.7),
              AppTheme.surface,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.gold.withValues(alpha: 0.02),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  shape: BoxShape.circle,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: 1500.ms,
                delay: (index * 100).ms,
                color: AppTheme.gold.withValues(alpha: 0.05),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(
                      duration: 1500.ms,
                      delay: (index * 100 + 50).ms,
                      color: AppTheme.gold.withValues(alpha: 0.08),
                    ),
                    const Gap(8),
                    Container(
                      height: 12,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(
                      duration: 1500.ms,
                      delay: (index * 100 + 100).ms,
                      color: AppTheme.gold.withValues(alpha: 0.05),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
      .animate()
      .fadeIn(delay: (index * 80).ms, duration: 400.ms)
      .slideY(begin: 0.3, end: 0),
    );
  }
}
