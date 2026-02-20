import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/auth/presentation/auth_notifier.dart';
import 'package:altin_takip/features/auth/presentation/auth_state.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:altin_takip/core/widgets/password_strength_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altin_takip/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:iconsax/iconsax.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next is AuthAuthenticated || next is AuthEncryptionRequired) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }
      if (next is AuthUnauthenticated && next.error != null) {
        AppNotification.show(
          context,
          message: next.error!,
          type: NotificationType.error,
        );
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

                  const Gap(32),

                  // ── Header ──
                  Text(
                    'Hesap\nOluştur',
                    style: context.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 40,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  const Gap(12),
                  Text(
                    'Birkaç saniyede portföyünüzü takibe başlayın',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 15,
                      letterSpacing: -0.2,
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const Gap(48),

                  // ── Email ──
                  _buildTextField(
                    controller: _emailController,
                    hint: 'E-posta Adresi',
                    icon: Iconsax.sms,
                    keyboardType: TextInputType.emailAddress,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.04),

                  const Gap(12),

                  // ── Password ──
                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Şifre',
                    icon: Iconsax.lock,
                    obscureText: _isObscured,
                    onChanged: (_) => setState(() {}),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscured ? Iconsax.eye : Iconsax.eye_slash,
                        size: 18,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      onPressed: () =>
                          setState(() => _isObscured = !_isObscured),
                    ),
                  ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.04),

                  PasswordStrengthIndicator(
                    password: _passwordController.text,
                  ).animate().fadeIn(delay: 280.ms),

                  const Gap(32),

                  // ── Register Button ──
                  SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleRegister,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'Kayıt Ol',
                                  style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 320.ms)
                      .scale(begin: const Offset(0.98, 0.98)),

                  const Gap(24),

                  // ── Or Divider ──
                  _OrDivider().animate().fadeIn(delay: 370.ms),

                  const Gap(24),

                  // ── Google Button ──
                  GoogleSignInButton(
                    label: 'Google ile Kayıt Ol',
                    onPressed: isLoading
                        ? null
                        : () =>
                              ref.read(authProvider.notifier).loginWithGoogle(),
                    isLoading: isLoading,
                  ).animate().fadeIn(delay: 420.ms).slideY(begin: 0.04),

                  const Spacer(),

                  // ── Login Link ──
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: RichText(
                        text: TextSpan(
                          text: 'Zaten hesabınız var mı?  ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 14,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Giriş Yap',
                              style: TextStyle(
                                color: AppTheme.gold,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                  const Gap(24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        suffixIcon: suffixIcon,
      ),
    );
  }

  void _handleRegister() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      AppNotification.show(
        context,
        message: 'Lütfen e-posta adresinizi girin',
        type: NotificationType.error,
      );
      return;
    }

    if (password.isEmpty) {
      AppNotification.show(
        context,
        message: 'Lütfen şifre belirleyin',
        type: NotificationType.error,
      );
      return;
    }

    if (password.length < 6) {
      AppNotification.show(
        context,
        message: 'Şifreniz en az 6 karakter olmalıdır',
        type: NotificationType.error,
      );
      return;
    }

    ref.read(authProvider.notifier).register(email, password);
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

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.06))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'veya e-posta ile',
            style: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.06))),
      ],
    );
  }
}
