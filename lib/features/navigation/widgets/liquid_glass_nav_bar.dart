import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';

class LiquidGlassNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isShrunk;
  final ValueChanged<int> onTap;

  const LiquidGlassNavBar({
    super.key,
    required this.currentIndex,
    required this.isShrunk,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double xAlign = -1.0 + currentIndex * (2.0 / 3.0);

    // Subtle sizing adjustments
    final double barHeight = isShrunk ? 56.0 : 64.0;
    final double bubbleHeight = isShrunk ? 38.0 : 44.0;
    final double bubbleWidth = isShrunk ? 44.0 : 52.0;
    final double iconSize = isShrunk ? 20.0 : 24.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      height: barHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1.0,
              ),
            ),
            child: Stack(
              children: [
                // Sliding Liquid Bubble
                AnimatedAlign(
                  alignment: Alignment(xAlign, 0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.fastOutSlowIn,
                  child: FractionallySizedBox(
                    widthFactor: 0.25,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.fastOutSlowIn,
                        width: bubbleWidth,
                        height: bubbleHeight,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.09),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Navigation Items Row
                Row(
                  children: [
                    _NavBarItem(
                      icon: Iconsax.home5,
                      inactiveIcon: Iconsax.home,
                      isSelected: currentIndex == 0,
                      iconSize: iconSize,
                      onTap: () => onTap(0),
                    ),
                    _NavBarItem(
                      icon: Iconsax.wallet_3,
                      inactiveIcon: Iconsax.wallet_3,
                      isSelected: currentIndex == 1,
                      iconSize: iconSize,
                      onTap: () => onTap(1),
                    ),
                    _NavBarItem(
                      icon: Iconsax.flag5,
                      inactiveIcon: Iconsax.flag,
                      isSelected: currentIndex == 2,
                      iconSize: iconSize,
                      onTap: () => onTap(2),
                    ),
                    _NavBarItem(
                      icon: Iconsax.setting_2,
                      inactiveIcon: Iconsax.setting_2,
                      isSelected: currentIndex == 3,
                      iconSize: iconSize,
                      onTap: () => onTap(3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData inactiveIcon;
  final bool isSelected;
  final double iconSize;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.inactiveIcon,
    required this.isSelected,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color defaultColor = isSelected
        ? AppTheme.gold
        : Colors.white.withOpacity(0.4);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedScale(
            scale: isSelected ? 1.05 : 0.95,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isSelected ? icon : inactiveIcon,
              color: defaultColor,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
