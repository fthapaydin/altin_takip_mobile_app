import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/auth/presentation/auth_notifier.dart';
import 'package:altin_takip/features/auth/presentation/auth_state.dart';
import 'package:altin_takip/features/auth/presentation/reset_password_screen.dart'; // Will create next
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next is AuthUnauthenticated) {
        if (next.error != null) {
          AppNotification.show(
            context,
            message: next.error!,
            type: NotificationType.error,
          );
        } else if (previous is AuthLoading) {
           AppNotification.show(
            context,
            message: 'Doğrulama kodu e-posta adresinize gönderildi.',
            type: NotificationType.success,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ResetPasswordScreen(),
            ),
          );
        }
      }
    });

    final state = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Şifremi Unuttum'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(24),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFffbf00), Color(0xFFb8860b)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFb8860b).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 40,
                    color: Colors.black,
                  ),
                ),
              ).animate().scale().fadeIn(),
              const Gap(32),
              Text(
                'Şifrenizi mi Unuttunuz?',
                style: context.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.gold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
              const Gap(16),
              Text(
                'E-posta adresinizi girin, şifrenizi sıfırlamanız için kod gönderelim.',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
              const Gap(48),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'E-posta Adresi',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ).animate().fadeIn(delay: 300.ms).slideX(),
              const Gap(32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state is AuthLoading
                      ? null
                      : () {
                          final email = _emailController.text.trim();
                          if (email.isEmpty) {
                            AppNotification.show(
                              context,
                              message: 'Lütfen e-posta adresinizi girin',
                              type: NotificationType.error,
                            );
                            return;
                          }
                          ref.read(authProvider.notifier).forgotPassword(email);
                        },
                  child: state is AuthLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('Kod Gönder'),
                            Gap(8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                ),
              ).animate().fadeIn(delay: 400.ms).scale(),
            ],
          ),
        ),
      ),
    );
  }
}
