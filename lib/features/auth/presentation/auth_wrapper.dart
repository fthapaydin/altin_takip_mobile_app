import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/features/auth/presentation/auth_notifier.dart';
import 'package:altin_takip/features/auth/presentation/auth_state.dart';
import 'package:altin_takip/features/public_prices/presentation/public_home_screen.dart';
import 'package:altin_takip/features/navigation/main_shell.dart';
import 'package:altin_takip/features/splash/presentation/splash_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState is AuthInitial || authState is AuthLoading) {
      return const SplashScreen();
    }

    if (authState is AuthAuthenticated || authState is AuthEncryptionRequired) {
      return const MainShell();
    }

    return const PublicHomeScreen();
  }
}
