import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/settings/presentation/settings_notifier.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';

class DeleteAccountSheet extends ConsumerWidget {
  const DeleteAccountSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const DeleteAccountSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();

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
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.trash,
                color: Colors.redAccent,
                size: 28,
              ),
            ),
            const Gap(16),
            const Text(
              'Hesabı Kalıcı Olarak Sil',
              style: TextStyle(
                fontWeight: FontWeight.w400, // No bold
                fontSize: 16, // Smaller, elegant size
                color: Colors.white, // Standard color instead of aggressive red
                letterSpacing: -0.5,
              ),
            ),
            const Gap(8),
            Text(
              'Bu işlem geri alınamaz. Tüm verileriniz kalıcı olarak silinecektir.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Gap(24),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              decoration: InputDecoration(
                hintText: 'Onaylamak için şifrenizi girin',
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
            const Gap(32),
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (passwordController.text.isEmpty) {
                        AppNotification.show(
                          context,
                          message: 'Şifre gerekli',
                          type: NotificationType.error,
                        );
                        return;
                      }
                      Navigator.pop(context);
                      ref
                          .read(settingsProvider.notifier)
                          .deleteAccount(password: passwordController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red.withOpacity(0.2)),
                      ),
                    ),
                    child: const Text(
                      'Hesabı Sil',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
