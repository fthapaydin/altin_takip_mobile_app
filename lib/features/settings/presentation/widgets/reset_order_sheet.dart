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
            style: TextStyle(
              fontWeight: FontWeight.w400, // No bold
              fontSize: 16, // Elegant size
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const Gap(8),
          Text(
            'Varlık ve gösterge sıralamalarınız varsayılana döndürülecektir. Emin misiniz?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Gap(24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Vazgeç',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold.withOpacity(0.1),
                    foregroundColor: AppTheme.gold,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppTheme.gold.withOpacity(0.2)),
                    ),
                  ),
                  child: const Text(
                    'Sıfırla',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
