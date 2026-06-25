import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altin_takip/features/chat/domain/conversation.dart';
import 'package:altin_takip/features/chat/presentation/chat_notifier.dart';
import 'package:altin_takip/features/chat/presentation/chat_room_screen.dart';

/// Card row displaying details for an individual chat conversation.
class ChatConversationCard extends ConsumerWidget {
  final Conversation conv;
  final int index;
  final VoidCallback onLongPress;

  const ChatConversationCard({
    super.key,
    required this.conv,
    required this.index,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(chatRoomProvider.notifier).setConversation(conv);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatRoomScreen()),
          );
        },
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.03),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Iconsax.message_text,
                color: Colors.white.withValues(alpha: 0.6),
                size: 20,
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      conv.title,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Text(
                      DateFormat('dd MMM yyyy', 'tr_TR').format(conv.createdAt),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 12,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.2),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(delay: (index * 40).ms, duration: 300.ms)
    .slideX(begin: -0.1, end: 0, curve: Curves.easeOut);
  }
}
