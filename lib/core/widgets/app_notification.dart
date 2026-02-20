import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

enum NotificationType { success, error, info }

class AppNotification {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required String message,
    NotificationType type = NotificationType.info,
  }) {
    // Dismiss any existing notification
    _currentEntry?.remove();
    _currentEntry = null;

    // Haptic feedback
    HapticFeedback.lightImpact();

    final overlay = Overlay.of(context);
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _NotificationOverlay(
        message: message,
        type: type,
        onDismiss: () {
          entry.remove();
          if (_currentEntry == entry) _currentEntry = null;
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 4), () {
      if (_currentEntry == entry) {
        entry.remove();
        _currentEntry = null;
      }
    });
  }
}

// ─────────────────────────────────────────────

class _NotificationOverlay extends StatelessWidget {
  final String message;
  final NotificationType type;
  final VoidCallback onDismiss;

  const _NotificationOverlay({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 12,
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
            onDismiss();
          }
        },
        onTap: onDismiss,
        child: Material(
          color: Colors.transparent,
          child: _NotificationCard(message: message, type: type),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final String message;
  final NotificationType type;

  const _NotificationCard({required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    final config = _NotificationConfig.from(type);

    return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: config.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: config.accentColor.withOpacity(0.15),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  // Accent icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: config.accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      config.icon,
                      color: config.accentColor,
                      size: 20,
                    ),
                  ),
                  const Gap(14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          config.title,
                          style: TextStyle(
                            color: config.accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const Gap(3),
                        Text(
                          message,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                            letterSpacing: -0.1,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  // Dismiss hint
                  Icon(
                    Iconsax.close_circle,
                    color: Colors.white.withOpacity(0.15),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 250.ms, curve: Curves.easeOut)
        .slideY(
          begin: -1.2,
          end: 0,
          duration: 450.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

// ─────────────────────────────────────────────

class _NotificationConfig {
  final Color accentColor;
  final Color backgroundColor;
  final IconData icon;
  final String title;

  const _NotificationConfig({
    required this.accentColor,
    required this.backgroundColor,
    required this.icon,
    required this.title,
  });

  factory _NotificationConfig.from(NotificationType type) {
    return switch (type) {
      NotificationType.success => const _NotificationConfig(
        accentColor: Color(0xFF34C759),
        backgroundColor: Color(0xE61C1C1E),
        icon: Iconsax.tick_circle,
        title: 'Başarılı',
      ),
      NotificationType.error => const _NotificationConfig(
        accentColor: Color(0xFFFF453A),
        backgroundColor: Color(0xE61C1C1E),
        icon: Iconsax.warning_2,
        title: 'Hata',
      ),
      NotificationType.info => const _NotificationConfig(
        accentColor: Color(0xFFFFD700),
        backgroundColor: Color(0xE61C1C1E),
        icon: Iconsax.info_circle,
        title: 'Bilgi',
      ),
    };
  }
}
