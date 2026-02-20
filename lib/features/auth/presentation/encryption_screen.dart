import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/auth/presentation/auth_notifier.dart';
import 'package:altin_takip/features/auth/presentation/auth_state.dart';
import 'package:altin_takip/features/assets/presentation/asset_notifier.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EncryptionScreen extends ConsumerStatefulWidget {
  const EncryptionScreen({super.key});

  @override
  ConsumerState<EncryptionScreen> createState() => _EncryptionScreenState();
}

class _EncryptionScreenState extends ConsumerState<EncryptionScreen> {
  final _keyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next is AuthEncryptionRequired && next.error != null) {
        AppNotification.show(
          context,
          message: next.error!,
          type: NotificationType.error,
        );
      }
      if (next is AuthAuthenticated && previous is AuthEncryptionRequired) {
        AppNotification.show(
          context,
          message: 'Şifreleme anahtarı doğrulandı.',
          type: NotificationType.success,
        );
        // Refresh assets and close screen
        ref.read(assetProvider.notifier).loadDashboard(refresh: true);
        Navigator.pop(context);
      }
    });

    final state = ref.watch(authProvider);
    final isLoading = state is AuthEncryptionRequired && state.isLoading;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight -
                      48, // 48 is total vertical padding
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Gap(40),
                    Text(
                      'Şifreleme Anahtarı',
                      style: context.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppTheme.gold,
                      ),
                    ).animate().fadeIn().slideX(),
                    const Gap(8),
                    Text(
                      'Hesabınız şifrelenmiş. Varlıklarınızı görüntülemek için şifreleme anahtarınızı girin.',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ).animate().fadeIn(delay: 100.ms).slideX(),
                    const Gap(48),
                    TextField(
                      controller: _keyController,
                      obscureText: true,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        hintText: 'Şifreleme Şifresi / Anahtarı',
                        prefixIcon: Icon(Icons.lock_person_outlined),
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                    const Gap(32),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_keyController.text.isNotEmpty) {
                                ref
                                    .read(authProvider.notifier)
                                    .setEncryptionKey(_keyController.text);
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text('Devam Et'),
                    ).animate().fadeIn(delay: 300.ms).scale(),
                    const Gap(16),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Vazgeç',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                    const Gap(40), // Bottom spacer
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
