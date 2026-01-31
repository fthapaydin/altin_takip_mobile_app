import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:altin_takip/features/chat/presentation/chat_notifier.dart';
import 'package:altin_takip/features/chat/presentation/chat_state.dart';
import 'package:altin_takip/features/chat/presentation/chat_room_screen.dart';
import 'package:altin_takip/features/chat/domain/conversation.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(chatHistoryProvider.notifier).loadConversations(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatHistoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
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
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Yapay Zeka Danışmanı',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.gold.withOpacity(0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),
            // Progress Indicator for Deletion
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
            // Divider
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.gold.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Content
            Expanded(
              child: switch (state) {
                ChatHistoryInitial() ||
                ChatHistoryLoading() => _buildSkeleton(),
                ChatHistoryError(message: final msg) => _buildError(msg),
                ChatHistoryLoaded(conversations: final list) => _buildList(
                  list,
                ),
              },
            ),
          ],
        ),
      ),
      floatingActionButton:
          Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.gold.withOpacity(0.3),
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
                  child: const Icon(
                    Iconsax.message_text,
                    color: Colors.black,
                    size: 26,
                  ),
                ),
              )
              .animate()
              .scale(delay: 400.ms, duration: 600.ms, curve: Curves.elasticOut)
              .then()
              .shimmer(
                delay: 200.ms,
                duration: 1500.ms,
                color: Colors.white.withOpacity(0.4),
              ),
    );
  }

  Widget _buildList(List conversations) {
    if (conversations.isEmpty &&
        ref.read(chatHistoryProvider) is ChatHistoryLoaded) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: Colors.white.withOpacity(0.1),
            ),
            const Gap(16),
            Text(
              'Henüz sohbet yok.\nYeni bir analiz başlatın!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.3)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(chatHistoryProvider.notifier)
          .loadConversations(isRefreshing: true),
      color: AppTheme.gold,
      backgroundColor: AppTheme.surface,
      strokeWidth: 2,
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: conversations.length,
        separatorBuilder: (_, __) => const Gap(16),
        itemBuilder: (context, index) {
          final conv = conversations[index] as Conversation;
          return _buildConversationCard(conv, index);
        },
      ),
    );
  }

  Widget _buildConversationCard(Conversation conv, int index) {
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
            onLongPress: () => _showDeleteConfirmation(conv),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.03),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Simple icon
                  Icon(
                    Iconsax.message_text,
                    color: Colors.white.withOpacity(0.6),
                    size: 20,
                  ),
                  const Gap(14),
                  // Conversation title and date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          conv.title,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(4),
                        Text(
                          DateFormat(
                            'dd MMM yyyy',
                            'tr_TR',
                          ).format(conv.createdAt),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 12,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Simple chevron
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withOpacity(0.2),
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

  void _showDeleteConfirmation(Conversation conv) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.trash, color: Colors.red, size: 32),
            ),
            const Gap(24),
            const Text(
              'Sohbeti Sil',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Gap(12),
            Text(
              'Bu sohbeti ve tüm mesajları kalıcı olarak silmek istediğinize emin misiniz?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const Gap(32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Vazgeç',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final result = await ref
                          .read(chatHistoryProvider.notifier)
                          .deleteConversation(conv.id);

                      result.fold(
                        (failure) {
                          if (!mounted) return;
                          AppNotification.show(
                            context,
                            message: failure.message,
                            type: NotificationType.error,
                          );
                        },
                        (_) {
                          if (!mounted) return;
                          AppNotification.show(
                            context,
                            message: 'Sohbet başarıyla silindi.',
                            type: NotificationType.success,
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Sil',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startNewConversation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NewChatSheet(),
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: 5,
      separatorBuilder: (_, __) => const Gap(16),
      itemBuilder: (_, index) =>
          Container(
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.surface,
                      AppTheme.surface.withOpacity(0.7),
                      AppTheme.surface,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.03)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.gold.withOpacity(0.02),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Avatar skeleton
                      Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              shape: BoxShape.circle,
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(
                            duration: 1500.ms,
                            delay: (index * 100).ms,
                            color: AppTheme.gold.withOpacity(0.05),
                          ),
                      const Gap(16),
                      // Text skeleton
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                  height: 16,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                )
                                .animate(
                                  onPlay: (controller) => controller.repeat(),
                                )
                                .shimmer(
                                  duration: 1500.ms,
                                  delay: (index * 100 + 50).ms,
                                  color: AppTheme.gold.withOpacity(0.08),
                                ),
                            const Gap(8),
                            Container(
                                  height: 12,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                )
                                .animate(
                                  onPlay: (controller) => controller.repeat(),
                                )
                                .shimmer(
                                  duration: 1500.ms,
                                  delay: (index * 100 + 100).ms,
                                  color: AppTheme.gold.withOpacity(0.05),
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: (index * 80).ms, duration: 400.ms)
              .slideY(begin: 0.3, end: 0),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Text(msg, style: const TextStyle(color: Colors.red)),
    );
  }
}

class _NewChatSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_NewChatSheet> createState() => _NewChatSheetState();
}

class _NewChatSheetState extends ConsumerState<_NewChatSheet> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.surface.withOpacity(0.98),
            AppTheme.background.withOpacity(0.98),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: AppTheme.gold.withOpacity(0.2), width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(24),
          // AI Icon Header
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.gold.withOpacity(0.2),
                  AppTheme.gold.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.gold.withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.gold.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Iconsax.magic_star,
              color: AppTheme.gold,
              size: 36,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const Gap(20),
          // Title
          const Text(
            'Yeni Sohbet Başlat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Gap(8),
          Text(
            'Portföyünüz hakkında istediğiniz soruyu sorun',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(32),
          // Input Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _controller,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              maxLines: 3,
              minLines: 1,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Örn: Bu ay ne kadar kar elde ettim?',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
          ),
          const Gap(20),
          // Action Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.gold, AppTheme.gold.withOpacity(0.85)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gold.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _isLoading
                      ? null
                      : () async {
                          if (_controller.text.trim().isEmpty) return;

                          setState(() => _isLoading = true);

                          final message = _controller.text.trim();
                          final notifier = ref.read(chatRoomProvider.notifier);
                          final historyNotifier = ref.read(
                            chatHistoryProvider.notifier,
                          );

                          // Start the conversation
                          await notifier.startNewChat(message);

                          if (!mounted) return;

                          setState(() => _isLoading = false);

                          // Check the result
                          final chatState = ref.read(chatRoomProvider);
                          dev.log('Chat state: ${chatState.runtimeType}');

                          // Close the bottom sheet
                          Navigator.pop(context);

                          if (chatState is ChatRoomLoaded) {
                            // Success - navigate to chat room
                            dev.log('Navigating to chat room');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChatRoomScreen(),
                              ),
                            );
                          } else if (chatState is ChatRoomError) {
                            // Error - show message
                            dev.log('Showing error: ${chatState.message}');
                            AppNotification.show(
                              context,
                              message: chatState.message,
                              type: NotificationType.error,
                            );
                            // Refresh conversation list
                            historyNotifier.loadConversations(
                              isRefreshing: true,
                            );
                          }
                        },
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Gönder',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                ),
                              ),
                              Gap(10),
                              Icon(
                                Iconsax.send_1,
                                color: Colors.black,
                                size: 20,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Fixed RoundedRectangleArray typo in build
class RoundedRectangleArray extends RoundedRectangleBorder {
  const RoundedRectangleArray({super.borderRadius});
}
