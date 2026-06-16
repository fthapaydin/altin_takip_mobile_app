import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/features/assets/presentation/assets_screen.dart';
import 'package:altin_takip/features/assets/presentation/add_asset_screen.dart';
import 'package:altin_takip/features/goals/presentation/goals_screen.dart';
import 'package:altin_takip/features/dashboard/presentation/dashboard_screen.dart';
import 'package:altin_takip/features/settings/presentation/settings_screen.dart';
import 'package:altin_takip/features/navigation/widgets/liquid_glass_nav_bar.dart';
import 'package:altin_takip/core/providers/scroll_state_provider.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    AssetsScreen(),
    GoalsScreen(),
    SettingsScreen(),
  ];

  void _showAddAssetScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAssetScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final isShrunk = ref.watch(scrollShrinkProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: true,
        body: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification.metrics.axis == Axis.vertical &&
                notification.depth == 0) {
              final double pixels = notification.metrics.pixels;
              final currentShrunk = ref.read(scrollShrinkProvider);
              if (pixels > 20 && !currentShrunk) {
                ref.read(scrollShrinkProvider.notifier).state = true;
              } else if (pixels <= 20 && currentShrunk) {
                ref.read(scrollShrinkProvider.notifier).state = false;
              }
            }
            return false;
          },
          child: Stack(
            children: [
              IndexedStack(index: _currentIndex, children: _screens),
              if (!keyboardVisible)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.fastOutSlowIn,
                    padding: EdgeInsets.only(
                      left: isShrunk ? 32.0 : 16.0,
                      right: isShrunk ? 32.0 : 16.0,
                      bottom: bottomInset > 0
                          ? bottomInset
                          : (isShrunk ? 8.0 : 12.0),
                    ),
                    child: LiquidGlassNavBar(
                      currentIndex: _currentIndex,
                      isShrunk: isShrunk,
                      onTap: (index) {
                        setState(() => _currentIndex = index);
                        ref.read(scrollShrinkProvider.notifier).state = false;
                      },
                      onAddTapped: _showAddAssetScreen,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
