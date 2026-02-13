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
      if (next is AuthUnauthenticated && next.error != null) {
        AppNotification.show(
          context,
          message: next.error!,
          type: NotificationType.error,
        );
      }
    });

    final state = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
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
                  const Gap(40),
                  Center(
                    child: Image.asset(
                      'assets/logo.png',
                      height: 100,
                      width: 100,
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                  ),
                  const Gap(24),
                  Text(
                    'Hoş Geldiniz',
                    style: context.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.gold,
                    ),
                  ).animate().fadeIn().slideX(),
                  const Gap(8),
                  Text(
                    'Portföyünüzü takip etmeye başlayın',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideX(),
                  const Gap(48),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'E-posta Adresi',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                  const Gap(16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _isObscured,
                    decoration: InputDecoration(
                      hintText: 'Şifre',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscured
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Şifremi Unuttum?',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 350.ms),
                  const Gap(16),
                  ElevatedButton(
                    onPressed: state is AuthLoading
                        ? null
                        : () {
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

                            ref
                                .read(authProvider.notifier)
                                .login(email, password);
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
                        : const Text('Giriş Yap'),
                  ).animate().fadeIn(delay: 400.ms).scale(),
                  const Spacer(),
                  const Gap(24),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Hesabınız yok mu? ',
                          style: context.textTheme.bodyMedium,
                          children: const [
                            TextSpan(
                              text: 'Kayıt Ol',
                              style: TextStyle(
                                color: AppTheme.gold,
                                fontWeight: FontWeight.bold,
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
}
