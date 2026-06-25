import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:altin_takip/features/chat/domain/conversation.dart';
import 'package:altin_takip/features/chat/presentation/chat_notifier.dart';

/// Bottom sheet confirmation modal for deleting a chat history item.
class ChatDeleteSheet extends ConsumerWidget {
  final Conversation conv;

  const ChatDeleteSheet({super.key, required this.conv});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: Colors.red.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.trash,
              color: Colors.redAccent,
              size: 36,
            ),
          ),
          const Gap(20),
          const Text(
            'Sohbeti Sil',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 16,
              letterSpacing: -0.5,
            ),
          ),
          const Gap(12),
          Text(
            'Bu sohbeti ve tüm mesajları kalıcı olarak silmek istediğinize emin misiniz?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const Gap(32),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.white.withValues(alpha: 0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Vazgeç',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              const Gap(16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await ref
                        .read(chatHistoryProvider.notifier)
                        .deleteConversation(conv.id);

                    result.fold(
                      (failure) {
                        if (!context.mounted) return;
                        AppNotification.show(
                          context,
                          message: failure.message,
                          type: NotificationType.error,
                        );
                      },
                      (_) {
                        if (!context.mounted) return;
                        AppNotification.show(
                          context,
                          message: 'Sohbet başarıyla silindi.',
                          type: NotificationType.success,
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.red.withValues(alpha: 0.2)),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sil',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
