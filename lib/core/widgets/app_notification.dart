import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';

enum NotificationType { success, error, info }

class AppNotification {
  static void show(
    BuildContext context, {
    required String message,
    NotificationType type = NotificationType.info,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: _NotificationWidget(message: message, type: type),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}

class _NotificationWidget extends StatelessWidget {
  final String message;
  final NotificationType type;

  const _NotificationWidget({required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      NotificationType.success => Colors.greenAccent,
      NotificationType.error => Colors.redAccent,
      NotificationType.info => AppTheme.gold,
    };

    final icon = switch (type) {
      NotificationType.success => Icons.check_circle_outline,
      NotificationType.error => Icons.error_outline,
      NotificationType.info => Icons.info_outline,
    };

    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Gap(12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.5, end: 0, curve: Curves.easeOutBack);
  }
}
