import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/assets/presentation/asset_notifier.dart';
import 'package:altin_takip/features/auth/presentation/auth_notifier.dart';
import 'package:altin_takip/features/auth/presentation/auth_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _dataPrefetched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPrefetch();
    });
  }

  void _checkAndPrefetch() {
    final authState = ref.read(authProvider);

    if (authState is AuthAuthenticated && !_dataPrefetched) {
      _dataPrefetched = true;
      ref.read(assetProvider.notifier).loadDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next is AuthAuthenticated && !_dataPrefetched) {
        _dataPrefetched = true;
        ref.read(assetProvider.notifier).loadDashboard();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Minimal Centered Logo (Instagram-like layout)
          Center(
            child: const Icon(Iconsax.wallet_3, size: 72, color: AppTheme.gold)
                .animate()
                .fadeIn(duration: 800.ms)
                .scaleXY(
                  begin: 0.85,
                  end: 1.0,
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                ),
          ),

          // Faint, elegant branding footer at the bottom (similar to "from Meta")
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: Text(
                'FatalSoft',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.15),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(duration: 800.ms, delay: 300.ms),
            ),
          ),
        ],
      ),
    );
  }
}
