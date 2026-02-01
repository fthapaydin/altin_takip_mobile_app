import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/settings/presentation/settings_notifier.dart';

class LogoutSheet extends ConsumerWidget {
  const LogoutSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const LogoutSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.gold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.logout, color: AppTheme.gold, size: 32),
          ),
          const Gap(20),
          const Text(
            'Çıkış Yap',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Gap(8),
          Text(
            'Oturumunuzu sonlandırmak istediğinize emin misiniz?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
          const Gap(24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Vazgeç'),
                ),
              ),
              const Gap(12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(settingsProvider.notifier).logout();
                  },
                  child: const Text('Çıkış Yap'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
