import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/auth/presentation/auth_notifier.dart';
import 'package:altin_takip/features/auth/presentation/auth_state.dart';
import 'package:altin_takip/features/auth/presentation/login_screen.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:altin_takip/core/widgets/password_strength_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordObscured = true;
  bool _isConfirmObscured = true;

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
            message: 'Şifreniz başarıyla sıfırlandı. Giriş yapabilirsiniz.',
            type: NotificationType.success,
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
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
                    'Yeni Şifre\nBelirleyin',
                    style: context.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 40,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  const Gap(16),
                  Text(
                    'E-posta ile gelen 5 haneli kodu ve\nyeni şifrenizi girin.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 15,
                      height: 1.5,
                      letterSpacing: -0.2,
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const Gap(48),

                  // ── Verification Code ──
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    style: const TextStyle(fontSize: 18, letterSpacing: 8),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '• • • • •',
                      counterText: '',
                      hintStyle: TextStyle(
                        letterSpacing: 8,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.04),

                  const Gap(16),

                  // ── New Password ──
                  TextField(
                    controller: _passwordController,
                    obscureText: _isPasswordObscured,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Yeni Şifre',
                      prefixIcon: const Icon(Iconsax.lock, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordObscured ? Iconsax.eye : Iconsax.eye_slash,
                          size: 18,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        onPressed: () => setState(
                          () => _isPasswordObscured = !_isPasswordObscured,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.04),

                  PasswordStrengthIndicator(
                    password: _passwordController.text,
                  ).animate().fadeIn(delay: 280.ms),

                  const Gap(16),

                  // ── Confirm Password ──
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _isConfirmObscured,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Yeni Şifre Tekrar',
                      prefixIcon: const Icon(Iconsax.lock, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmObscured ? Iconsax.eye : Iconsax.eye_slash,
                          size: 18,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        onPressed: () => setState(
                          () => _isConfirmObscured = !_isConfirmObscured,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 320.ms).slideY(begin: 0.04),

                  const Gap(32),

                  // ── Reset Button ──
                  SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleReset,
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
                                      'Şifreyi Güncelle',
                                      style: TextStyle(
                                        fontSize: 16,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    Gap(8),
                                    Icon(Iconsax.tick_circle, size: 18),
                                  ],
                                ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 380.ms)
                      .scale(begin: const Offset(0.98, 0.98)),

                  const Spacer(),
                  const Gap(80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleReset() {
    final code = _codeController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (code.length != 5) {
      AppNotification.show(
        context,
        message: 'Doğrulama kodu 5 haneli olmalıdır',
        type: NotificationType.error,
      );
      return;
    }

    if (password.length < 6) {
      AppNotification.show(
        context,
        message: 'Şifre en az 6 karakter olmalıdır',
        type: NotificationType.error,
      );
      return;
    }

    if (password != confirm) {
      AppNotification.show(
        context,
        message: 'Şifreler eşleşmiyor',
        type: NotificationType.error,
      );
      return;
    }

    ref.read(authProvider.notifier).resetPassword(code, password);
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
