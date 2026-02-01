import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/settings/presentation/preference_notifier.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';

class ResetOrderSheet extends ConsumerWidget {
  const ResetOrderSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ResetOrderSheet(),
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
              color: AppTheme.gold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.setting_4,
              color: AppTheme.gold,
              size: 32,
            ),
          ),
          const Gap(20),
          const Text(
            'Sıralamayı Sıfırla',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Gap(8),
          Text(
            'Varlık ve gösterge sıralamalarınız varsayılana döndürülecektir. Emin misiniz?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
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
                    ref.read(preferenceProvider.notifier).resetOrdering();
                    AppNotification.show(
                      context,
                      message: 'Sıralama tercihleri sıfırlandı',
                      type: NotificationType.success,
                    );
                  },
                  child: const Text('Sıfırla'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
