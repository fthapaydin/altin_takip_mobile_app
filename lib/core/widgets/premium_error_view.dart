import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';

class PremiumErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const PremiumErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.red.withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.1),
                        blurRadius: 24,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    color: Colors.red,
                    size: 48,
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 2000.ms,
                ),
            const Gap(32),
            const Text(
              'Bağlantı Hatası',
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
            ),
            const Gap(12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const Gap(32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shadowColor: AppTheme.gold.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded),
                    Gap(8),
                    Text('Tekrar Dene', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}
