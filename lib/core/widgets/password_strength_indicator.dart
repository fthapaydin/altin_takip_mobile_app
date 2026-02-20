import 'package:flutter/material.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:gap/gap.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final strength = _calculateStrength(password);
    final color = _getColor(strength);
    final text = _getText(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(8),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength / 4,
                backgroundColor: Colors.grey[800],
                color: color,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(12),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _calculateStrength(String password) {
    if (password.isEmpty) return 0;
    double score = 0;
    if (password.length > 6) score++;
    if (password.length > 10) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) score++;
    return score > 4 ? 4 : score; // Max score 4 for full bar
  }

  Color _getColor(double strength) {
    if (strength <= 1) return Colors.red;
    if (strength <= 2) return Colors.orange;
    if (strength <= 3) return Colors.yellow;
    return Colors.green;
  }

  String _getText(double strength) {
    if (strength == 0) return '';
    if (strength <= 1) return 'Zayıf';
    if (strength <= 2) return 'Orta';
    if (strength <= 3) return 'İyi';
    return 'Güçlü';
  }
}
