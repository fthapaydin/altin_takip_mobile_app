import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/assets/presentation/assets_screen.dart';
import 'package:altin_takip/features/assets/presentation/widgets/add_asset_bottom_sheet.dart';
import 'package:altin_takip/features/calculator/presentation/calculator_screen.dart';
import 'package:altin_takip/features/dashboard/presentation/dashboard_screen.dart';
import 'package:altin_takip/features/settings/presentation/settings_screen.dart';

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
    CalculatorScreen(),
    SettingsScreen(),
  ];

  void _showAddAssetBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddAssetBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if keyboard is visible
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: true,
        body: IndexedStack(index: _currentIndex, children: _screens),
        floatingActionButton: keyboardVisible
            ? null
            : FloatingActionButton(
                heroTag: null,
                onPressed: _showAddAssetBottomSheet,
                backgroundColor: AppTheme.gold,
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.black,
                  size: 28,
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: const Color(0xFF0D0D0D),
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          padding: EdgeInsets.zero,
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Anasayfa'),
              _buildNavItem(1, Icons.pie_chart_rounded, 'Portföy'),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(2, Icons.calculate_rounded, 'Hesaplama'),
              _buildNavItem(3, Icons.settings_rounded, 'Ayarlar'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.gold : Colors.white.withOpacity(0.4),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppTheme.gold
                    : Colors.white.withOpacity(0.4),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
