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
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.trash, color: Colors.red, size: 32),
            ),
            const Gap(20),
            const Text(
              'Hesabı Kalıcı Olarak Sil',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.red,
              ),
            ),
            const Gap(12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.warning_2, color: Colors.red, size: 20),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      'Bu işlem geri alınamaz! Tüm verileriniz ve işlem geçmişiniz kalıcı olarak silinecek.',
                      style: TextStyle(
                        color: Colors.red.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Onaylamak için şifrenizi girin',
                prefixIcon: Icon(Iconsax.lock, size: 20),
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
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Hesabı Sil'),
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
