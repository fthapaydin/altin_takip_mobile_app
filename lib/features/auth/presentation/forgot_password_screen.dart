import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/auth/presentation/auth_notifier.dart';
import 'package:altin_takip/features/auth/presentation/auth_state.dart';
import 'package:altin_takip/features/auth/presentation/reset_password_screen.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
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
    final isLoading = state is AuthLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(16),

                  // ── Back Button ──
                  _BackButton(),

                  const Gap(48),

                  // ── Header ──
                  Text(
                    'Şifrenizi mi\nUnuttunuz?',
                    style: context.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 40,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  const Gap(16),
                  Text(
                    'E-posta adresinizi girin, şifrenizi sıfırlamanız\niçin doğrulama kodu gönderelim.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 15,
                      height: 1.5,
                      letterSpacing: -0.2,
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const Gap(48),

                  // ── Email Input ──
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: 'E-posta Adresi',
                      prefixIcon: Icon(Iconsax.sms, size: 18),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.04),

                  const Gap(32),

                  // ── Send Code Button ──
                  SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleSendCode,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Kod Gönder',
                                      style: TextStyle(
                                        fontSize: 16,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    Gap(8),
                                    Icon(Iconsax.arrow_right_3, size: 18),
                                  ],
                                ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .scale(begin: const Offset(0.98, 0.98)),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSendCode() {
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
  }
}

// ─────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Iconsax.arrow_left,
          color: Colors.white.withOpacity(0.6),
          size: 20,
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }
}
