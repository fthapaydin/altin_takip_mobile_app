import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/chat/domain/conversation.dart';
import 'package:altin_takip/features/chat/presentation/chat_notifier.dart';
import 'package:altin_takip/features/chat/presentation/chat_state.dart';
import 'package:altin_takip/features/chat/presentation/widgets/chat_list_skeleton.dart';
import 'package:altin_takip/features/chat/presentation/widgets/chat_conversation_card.dart';
import 'package:altin_takip/features/chat/presentation/widgets/chat_delete_sheet.dart';
import 'package:altin_takip/features/chat/presentation/widgets/new_chat_sheet.dart';

/// Screen presenting the list of historical AI conversations and a floating trigger for new requests.
class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(chatHistoryProvider.notifier).loadConversations());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatHistoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    color: Colors.white,
                    iconSize: 20,
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      const Text(
                        'AI ASİSTAN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Yapay Zeka Danışmanı',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.gold.withValues(alpha: 0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            if (state is ChatHistoryLoaded && state.isDeleting)
              Container(
                height: 1.5,
                margin: const EdgeInsets.symmetric(horizontal: 48),
                child: const LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: AppTheme.gold,
                  minHeight: 1.5,
                ).animate().fadeIn(),
              ),
            const SizedBox(height: 8),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.gold.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: switch (state) {
                ChatHistoryInitial() || ChatHistoryLoading() => const ChatListSkeleton(),
                ChatHistoryError(message: final msg) => _buildError(msg),
                ChatHistoryLoaded(conversations: final list) => _buildList(list),
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.gold.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _startNewConversation(context),
          backgroundColor: AppTheme.gold,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Iconsax.message_text, color: Colors.black, size: 26),
        ),
      )
      .animate()
      .scale(delay: 400.ms, duration: 600.ms, curve: Curves.elasticOut)
      .then()
      .shimmer(
        delay: 200.ms,
        duration: 1500.ms,
        color: Colors.white.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildList(List conversations) {
    if (conversations.isEmpty && ref.read(chatHistoryProvider) is ChatHistoryLoaded) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.white.withValues(alpha: 0.1)),
            const Gap(16),
            Text(
              'Henüz sohbet yok.\nYeni bir analiz başlatın!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(chatHistoryProvider.notifier).loadConversations(isRefreshing: true),
      color: AppTheme.gold,
      backgroundColor: AppTheme.surface,
      strokeWidth: 2,
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: conversations.length,
        separatorBuilder: (_, __) => const Gap(16),
        itemBuilder: (context, index) {
          final conv = conversations[index] as Conversation;
          return ChatConversationCard(
            conv: conv,
            index: index,
            onLongPress: () => _showDeleteConfirmation(conv),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(Conversation conv) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ChatDeleteSheet(conv: conv),
    );
  }

  void _startNewConversation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewChatSheet(),
    );
  }

  Widget _buildError(String msg) {
    return Center(child: Text(msg, style: const TextStyle(color: Colors.red)));
  }
}
