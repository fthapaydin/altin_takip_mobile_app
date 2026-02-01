import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionHeader({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.gold, size: 18),
        const Gap(8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: AppTheme.gold,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
