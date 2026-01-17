import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/features/auth/presentation/auth_notifier.dart';
import 'package:altin_takip/features/auth/presentation/auth_state.dart';
import 'package:altin_takip/features/auth/presentation/login_screen.dart';
import 'package:altin_takip/features/auth/presentation/encryption_screen.dart';
import 'package:altin_takip/features/navigation/main_shell.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);

    return switch (state) {
      AuthAuthenticated _ => const MainShell(),
      AuthEncryptionRequired _ => const EncryptionScreen(),
      _ => const LoginScreen(),
    };
  }
}
