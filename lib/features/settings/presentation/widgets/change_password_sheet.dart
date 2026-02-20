import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/settings/presentation/settings_notifier.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';

class ChangePasswordSheet extends ConsumerWidget {
  const ChangePasswordSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ChangePasswordSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentController = TextEditingController();
    final newController = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.key,
                    color: AppTheme.gold,
                    size: 24,
                  ),
                ),
                const Gap(16),
                const Expanded(
                  child: Text(
                    'Şifre Değiştir',
                    style: TextStyle(
                      fontWeight: FontWeight.w400, // No bold
                      fontSize: 16, // Elegant size
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Iconsax.close_circle),
                ),
              ],
            ),
            const Gap(20),
            TextField(
              controller: currentController,
              obscureText: true,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              decoration: InputDecoration(
                hintText: 'Mevcut Şifre',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Iconsax.lock_1,
                  size: 18,
                  color: Colors.white.withOpacity(0.5),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.03),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.gold.withOpacity(0.3)),
                ),
              ),
            ),
            const Gap(12),
            TextField(
              controller: newController,
              obscureText: true,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              decoration: InputDecoration(
                hintText: 'Yeni Şifre',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Iconsax.lock,
                  size: 18,
                  color: Colors.white.withOpacity(0.5),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.03),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.gold.withOpacity(0.3)),
                ),
              ),
            ),
            const Gap(24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (currentController.text.isEmpty) {
                    AppNotification.show(
                      context,
                      message: 'Mevcut şifre boş olamaz',
                      type: NotificationType.error,
                    );
                    return;
                  }
                  if (newController.text.isEmpty) {
                    AppNotification.show(
                      context,
                      message: 'Yeni şifre boş olamaz',
                      type: NotificationType.error,
                    );
                    return;
                  }
                  Navigator.pop(context);
                  ref
                      .read(settingsProvider.notifier)
                      .changePassword(
                        currentPassword: currentController.text,
                        newPassword: newController.text,
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
                  'Şifreyi Güncelle',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
