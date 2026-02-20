import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/auth/presentation/auth_notifier.dart';
import 'package:altin_takip/features/auth/presentation/auth_state.dart';
import 'package:altin_takip/features/auth/presentation/register_screen.dart';
import 'package:altin_takip/features/auth/presentation/forgot_password_screen.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altin_takip/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:iconsax/iconsax.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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
                  const Gap(80),

                  // ── Header ──
                  Text(
                    'Hoş\nGeldiniz',
                    style: context.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 40,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  const Gap(12),
                  Text(
                    'Portföyünüzü takip etmeye başlayın',
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

                  const Gap(4),

                  // ── Forgot Password ──
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                      ),
                      child: Text(
                        'Şifremi Unuttum?',
                        style: TextStyle(
                          color: AppTheme.gold.withOpacity(0.7),
                          fontSize: 13,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const Gap(24),

                  // ── Login Button ──
                  SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
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
                                  'Giriş Yap',
                                  style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 350.ms)
                      .scale(begin: const Offset(0.98, 0.98)),

                  const Gap(24),

                  // ── Or Divider ──
                  _OrDivider().animate().fadeIn(delay: 400.ms),

                  const Gap(24),

                  // ── Google Button ──
                  GoogleSignInButton(
                    onPressed: isLoading
                        ? null
                        : () =>
                              ref.read(authProvider.notifier).loginWithGoogle(),
                    isLoading: isLoading,
                  ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.04),

                  const Spacer(),

                  // ── Register Link ──
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      child: RichText(
                        text: TextSpan(
                          text: 'Hesabınız yok mu?  ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 14,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Kayıt Ol',
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        suffixIcon: suffixIcon,
      ),
    );
  }

  void _handleLogin() {
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
        message: 'Lütfen şifrenizi girin',
        type: NotificationType.error,
      );
      return;
    }

    ref.read(authProvider.notifier).login(email, password);
  }
}

// ─────────────────────────────────────────────

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
