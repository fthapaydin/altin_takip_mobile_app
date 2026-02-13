import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/auth/presentation/auth_notifier.dart';
import 'package:altin_takip/features/auth/presentation/auth_state.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:altin_takip/core/widgets/password_strength_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Kayıt Ol'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(24),
                      Center(
                        child: Image.asset(
                          'assets/logo.png',
                          height: 80,
                          width: 80,
                        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                      ),
                      const Gap(24),
                      Text(
                        'Yeni Hesap Oluştur',
                        style: context.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.gold,
                        ),
                      ).animate().fadeIn().slideX(),
                      const Gap(8),
                      Text(
                        'Bilgilerinizi girerek hemen başlayın',
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideX(),
                      const Gap(32),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                hintText: 'Ad',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                          ),
                          const Gap(16),
                          Expanded(
                            child: TextField(
                              controller: _surnameController,
                              decoration: const InputDecoration(hintText: 'Soyad'),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                      const Gap(16),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'E-posta Adresi',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                      const Gap(16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        onChanged: (value) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Şifre',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                      PasswordStrengthIndicator(password: _passwordController.text)
                          .animate()
                          .fadeIn(delay: 450.ms),
                      const Gap(32),
                      ElevatedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                final name = _nameController.text.trim();
                                final surname = _surnameController.text.trim();
                                final email = _emailController.text.trim();
                                final password = _passwordController.text.trim();

                                if (name.isEmpty) {
                                  AppNotification.show(
                                    context,
                                    message: 'Lütfen adınızı girin',
                                    type: NotificationType.error,
                                  );
                                  return;
                                }

                                if (surname.isEmpty) {
                                  AppNotification.show(
                                    context,
                                    message: 'Lütfen soyadınızı girin',
                                    type: NotificationType.error,
                                  );
                                  return;
                                }

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

                                ref
                                    .read(authProvider.notifier)
                                    .register(name, surname, email, password);
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
                            : const Text('Kayıt Ol'),
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
