import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
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
          // Background Glow 1
          Positioned(
                top: MediaQuery.of(context).size.height * 0.2,
                right: -100,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.gold.withOpacity(0.12),
                    ),
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleXY(
                begin: 1.0,
                end: 1.2,
                duration: 4.seconds,
                curve: Curves.easeInOut,
              ),

          // Background Glow 2
          Positioned(
                bottom: MediaQuery.of(context).size.height * 0.2,
                left: -100,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent.withOpacity(0.08),
                    ),
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleXY(
                begin: 1.0,
                end: 1.15,
                duration: 5.seconds,
                curve: Curves.easeInOut,
              ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Premium Glass Logo Container
                Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.gold.withOpacity(0.05),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.gold.withOpacity(0.2),
                              AppTheme.gold.withOpacity(0.05),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.gold.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Iconsax.wallet_3, // Premium linear icon
                          size: 48,
                          color: AppTheme.gold,
                        ),
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scaleXY(
                      begin: 0.96,
                      end: 1.04,
                      duration: 2.seconds,
                      curve: Curves.easeInOut,
                    )
                    .shimmer(duration: 3.seconds, color: Colors.white24),

                const Gap(40),

                // App Name with elegant typography
                const Text(
                      'Altın Cüzdanın',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight:
                            FontWeight.w400, // Minimalist regular weight
                        letterSpacing: -1.0, // Tighter premium tracking
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 200.ms)
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 800.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const Gap(8),

                // Subtitle
                Text(
                  'Varlık Yönetimi',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 14,
                    letterSpacing: 2.0, // Widened tracking for subtitle
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(duration: 800.ms, delay: 400.ms),

                const Gap(48),

                // Elegant Loading Text instead of raw spinner
                Shimmer.fromColors(
                  baseColor: Colors.white.withOpacity(0.2),
                  highlightColor: AppTheme.gold.withOpacity(0.8),
                  child: const Text(
                    'Veriler Yükleniyor...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ).animate().fadeIn(duration: 800.ms, delay: 800.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
