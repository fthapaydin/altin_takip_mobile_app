import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/auth/presentation/encryption_screen.dart';

class LockedPortfolioView extends StatelessWidget {
  const LockedPortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.lock, color: AppTheme.gold, size: 48),
          ).animate().fadeIn().scale(),
          const Gap(24),
          const Text(
            'Portföy Kilitli',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
          const Gap(8),
          const Text(
            'Varlıklarınızı görüntülemek için\nşifreleme anahtarınızı girin.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          const Gap(32),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EncryptionScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Kilidi Aç',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ).animate().fadeIn(delay: 300.ms).scale(),
        ],
      ),
    );
  }
}
