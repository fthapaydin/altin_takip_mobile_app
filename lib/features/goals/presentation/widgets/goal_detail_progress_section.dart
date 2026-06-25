import 'package:flutter/material.dart';
import 'package:altin_takip/core/theme/app_theme.dart';

/// Circular progress ring displaying the completion status of a goal.
class GoalDetailProgressSection extends StatelessWidget {
  final double normalized;
  final double percentage;

  const GoalDetailProgressSection({
    super.key,
    required this.normalized,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: CircularProgressIndicator(
                value: normalized,
                strokeWidth: 8,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.white.withValues(alpha: 0.06),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '%${percentage.toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  'tamamlandı',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
