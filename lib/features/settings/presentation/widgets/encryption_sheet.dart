import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/settings/presentation/settings_notifier.dart';
import 'package:altin_takip/features/settings/presentation/settings_state.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';

class EncryptionSheet extends StatefulWidget {
  final bool enable;
  final ValueChanged<bool> onSuccess;

  const EncryptionSheet({
    super.key,
    required this.enable,
    required this.onSuccess,
  });

  static void show(
    BuildContext context,
    bool enable,
    ValueChanged<bool> onSuccess,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EncryptionSheet(enable: enable, onSuccess: onSuccess),
    );
  }

  @override
  State<EncryptionSheet> createState() => _EncryptionSheetState();
}

class _EncryptionSheetState extends State<EncryptionSheet> {
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Assuming initial state is opposite of what we want to do, but logic is handled by parent mostly
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(settingsProvider);
        final isLoading =
            state is SettingsLoading && state.operation == 'encryption';

        ref.listen<SettingsState>(settingsProvider, (prev, next) {
          if (next is SettingsSuccess &&
              (next.message.contains('Şifreleme') ||
                  next.message.contains('şifreleme'))) {
            Navigator.of(context).pop();
            widget.onSuccess(widget.enable);
          } else if (next is SettingsError &&
              prev is SettingsLoading &&
              prev.operation == 'encryption') {
            // Error handling if needed
          }
        });

        return PopScope(
          canPop: !isLoading,
          child: Padding(
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
                          color: AppTheme.gold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.enable ? Iconsax.lock : Iconsax.unlock,
                          color: AppTheme.gold,
                          size: 24,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Text(
                          widget.enable
                              ? 'Şifrelemeyi Etkinleştir'
                              : 'Şifrelemeyi Kapat',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400, // No bold
                            fontSize: 16, // Elegant size
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      if (!isLoading)
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Iconsax.close_circle),
                        ),
                    ],
                  ),
                  const Gap(16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.info_circle,
                          size: 18,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Text(
                            widget.enable
                                ? 'Verilerinizi korumak için bir şifre belirleyin. Bu şifre olmadan verilerinize erişilemez.'
                                : 'Şifrelemeyi kapatmak için mevcut şifrenizi girin.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    enabled: !isLoading,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.enable
                          ? 'Şifre belirleyin'
                          : 'Mevcut şifrenizi girin',
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
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.gold.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  const Gap(24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white.withOpacity(0.7),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'İptal',
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
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_passwordController.text.isEmpty) {
                                    AppNotification.show(
                                      context,
                                      message: 'Şifre boş olamaz',
                                      type: NotificationType.error,
                                    );
                                    return;
                                  }
                                  ref
                                      .read(settingsProvider.notifier)
                                      .toggleEncryption(
                                        enable: widget.enable,
                                        password: _passwordController.text,
                                      );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.gold.withOpacity(0.1),
                            foregroundColor: AppTheme.gold,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: AppTheme.gold.withOpacity(0.2),
                              ),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.gold,
                                  ),
                                )
                              : Text(
                                  widget.enable ? 'Etkinleştir' : 'Kapat',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
