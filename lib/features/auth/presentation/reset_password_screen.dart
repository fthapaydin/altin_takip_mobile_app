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

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Şifre Sıfırla'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
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
                            Icons.vpn_key_outlined,
                            size: 40,
                            color: Colors.black,
                          ),
                        ),
                      ).animate().scale().fadeIn(),
                      const Gap(32),
                      Text(
                        'Yeni Şifre Belirleyin',
                        style: context.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.gold,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                      const Gap(16),
                      Text(
                        'E-posta ile gelen 5 haneli kodu ve yeni şifrenizi girin.',
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                      const Gap(48),
                      TextField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        decoration: const InputDecoration(
                          hintText: 'Doğrulama Kodu',
                          counterText: '',
                          prefixIcon: Icon(Icons.numbers),
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideX(),
                      const Gap(16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _isPasswordObscured,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Yeni Şifre',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordObscured
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordObscured = !_isPasswordObscured;
                              });
                            },
                          ),
                        ),
                      ).animate().fadeIn(delay: 350.ms).slideX(),
                      PasswordStrengthIndicator(
                        password: _passwordController.text,
                      ).animate().fadeIn(delay: 400.ms),
                      const Gap(16),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _isConfirmObscured,
                        decoration: InputDecoration(
                          hintText: 'Yeni Şifre Tekrar',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmObscured
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmObscured = !_isConfirmObscured;
                              });
                            },
                          ),
                        ),
                      ).animate().fadeIn(delay: 450.ms).slideX(),
                      const Gap(32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  final code = _codeController.text.trim();
                                  final password = _passwordController.text
                                      .trim();
                                  final confirm = _confirmPasswordController
                                      .text
                                      .trim();

                                  if (code.length != 5) {
                                    AppNotification.show(
                                      context,
                                      message:
                                          'Doğrulama kodu 5 haneli olmalıdır',
                                      type: NotificationType.error,
                                    );
                                    return;
                                  }

                                  if (password.length < 6) {
                                    AppNotification.show(
                                      context,
                                      message:
                                          'Şifre en az 6 karakter olmalıdır',
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

                                  ref
                                      .read(authProvider.notifier)
                                      .resetPassword(code, password);
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
                                    Text('Şifreyi Güncelle'),
                                    Gap(8),
                                    Icon(Icons.check_circle_outline, size: 18),
                                  ],
                                ),
                        ),
                      ).animate().fadeIn(delay: 500.ms).scale(),
                      const Spacer(),
                      const Gap(80), // Extra bottom padding
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
