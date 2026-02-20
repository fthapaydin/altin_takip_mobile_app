import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:altin_takip/features/chat/presentation/chat_notifier.dart';
import 'package:altin_takip/features/chat/presentation/chat_state.dart';
import 'package:altin_takip/features/chat/domain/chat_message.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  const ChatRoomScreen({super.key});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 && !_showScrollToBottom) {
      setState(() => _showScrollToBottom = true);
    } else if (_scrollController.offset <= 200 && _showScrollToBottom) {
      setState(() => _showScrollToBottom = false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Removed manual scroll logic as reverse: true handles it better

  @override
  Widget build(BuildContext context) {
    // Listen for errors
    ref.listen(chatRoomProvider, (previous, next) {
      if (next is ChatRoomLoaded && next.error != null) {
        AppNotification.show(
          context,
          message: next.error!,
          type: NotificationType.error,
        );
      } else if (next is ChatRoomError) {
        AppNotification.show(
          context,
          message: next.message,
          type: NotificationType.error,
        );
      }
    });

    final state = ref.watch(chatRoomProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(state),
            Expanded(child: _buildMessageList(state)),
            _buildInputArea(state),
          ],
        ),
      ),
      floatingActionButton: _showScrollToBottom
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton.small(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: 300.ms,
                    curve: Curves.easeOut,
                  );
                  HapticFeedback.mediumImpact();
                },
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.black,
                child: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
              ).animate().scale(duration: 200.ms).fadeIn(),
            )
          : null,
    );
  }

  Widget _buildHeader(ChatRoomState state) {
    return Column(
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
                  Text(
                    state is ChatRoomLoaded
                        ? state.conversation.title
                        : 'SOHBET',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppTheme.gold,
                              shape: BoxShape.circle,
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .fade(duration: 1000.ms)
                          .then()
                          .fade(duration: 1000.ms),
                      const Gap(6),
                      Text(
                        state is ChatRoomLoaded && state.isSending
                            ? 'Düşünüyor...'
                            : 'Yapay Zeka Danışmanı',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.gold.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
        ),
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
      ],
    );
  }

  Widget _buildMessageList(ChatRoomState state) {
    if (state is ChatRoomLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 3,
        itemBuilder: (context, index) => _buildMessageSkeleton(index),
      );
    }

    if (state is ChatRoomLoaded) {
      // Show skeleton while messages are loading
      if (state.messages.isEmpty && !state.isSending) {
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: 7,
          itemBuilder: (context, index) => _buildMessageSkeleton(index),
        );
      }

      final displayMessages = state.messages.reversed.toList();
      final hasTyping = state.isSending;

      return ListView.builder(
        controller: _scrollController,
        reverse: true,
        padding: const EdgeInsets.all(20),
        itemCount: displayMessages.length + (hasTyping ? 1 : 0) + 1,
        itemBuilder: (context, index) {
          if (index == displayMessages.length + (hasTyping ? 1 : 0)) {
            return _buildDisclaimer();
          }

          if (hasTyping && index == 0) {
            return _buildTypingIndicator();
          }

          final messageIndex = hasTyping ? index - 1 : index;
          if (messageIndex < 0 || messageIndex >= displayMessages.length) {
            return const SizedBox();
          }

          final message = displayMessages[messageIndex];
          final isLastMessage = index == (hasTyping ? 1 : 0);

          return _buildMessageBubble(message, isLastMessage, state);
        },
      );
    }

    return const SizedBox();
  }

  Widget _buildDisclaimer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 32, top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.gold.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.gold.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.gold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppTheme.gold,
              size: 20,
            ),
          ),
          const Gap(12),
          const Text(
            'Yasal Bilgilendirme',
            style: TextStyle(
              color: AppTheme.gold,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
          const Gap(8),
          Text(
            'Yapay Zeka Danışmanı tarafından sunulan analiz ve yorumlar tamamen bilgilendirme amaçlıdır. Bu bilgiler hiçbir şekilde yatırım tavsiyesi (YTD) niteliği taşımaz. Finansal kararlar almadan önce profesyonel bir uzmana danışmanız önerilir.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              height: 1.6,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageSkeleton(int index) {
    final isRight = index % 2 == 0;
    return Align(
      alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
      child:
          Container(
                margin: const EdgeInsets.only(bottom: 16),
                width:
                    MediaQuery.of(context).size.width * (isRight ? 0.6 : 0.7),
                height: 60 + (index * 10.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.03),
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isRight ? 20 : 0),
                    bottomRight: Radius.circular(isRight ? 0 : 20),
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .shimmer(
                delay: (index * 100).ms,
                duration: 1500.ms,
                color: AppTheme.gold.withOpacity(0.1),
              )
              .fadeIn(delay: (index * 80).ms, duration: 300.ms),
    );
  }

  Widget _buildMessageBubble(
    ChatMessage message,
    bool isLastMessage,
    ChatRoomLoaded state,
  ) {
    final isUser = message.isUser;
    final shouldAnimate =
        isLastMessage && !isUser && message.id == state.lastAddedMessageId;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: message.content));
          HapticFeedback.lightImpact();
          AppNotification.show(
            context,
            message: 'Mesaj kopyalandı',
            type: NotificationType.success,
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isUser ? AppTheme.gold : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isUser ? 20 : 0),
              bottomRight: Radius.circular(isUser ? 0 : 20),
            ),
            border: isUser
                ? null
                : Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: shouldAnimate
              ? _TypeWriterText(
                  key: ValueKey(message.id),
                  text: message.content,
                  isUser: isUser,
                )
              : Text(
                  message.content,
                  style: TextStyle(
                    color: isUser ? Colors.black : Colors.white,
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: isUser ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
        ),
      ).animate().fade(duration: 300.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: List.generate(3, (index) {
                return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: const BoxDecoration(
                        color: AppTheme.gold,
                        shape: BoxShape.circle,
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .scale(
                      delay: (index * 150).ms,
                      duration: 600.ms,
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1.2, 1.2),
                    )
                    .then()
                    .scale(
                      duration: 600.ms,
                      begin: const Offset(1.2, 1.2),
                      end: const Offset(0.6, 0.6),
                    );
              }),
            ),
            const Gap(12),
            Text(
              'AI Düşünüyor',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(ChatRoomState state) {
    final isLoading = state is ChatRoomLoaded && state.isSending;

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4, top: 8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _controller,
                autocorrect: false,
                enableSuggestions: false,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Mesajınızı yazın...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const Gap(12),
          GestureDetector(
            onTap: isLoading ? null : _handleSend,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.gold,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gold.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isLoading
                    ? Icons.hourglass_empty_rounded
                    : Icons.arrow_forward_rounded,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSend() {
    if (_controller.text.trim().isEmpty) return;
    ref.read(chatRoomProvider.notifier).sendMessage(_controller.text.trim());
    _controller.clear();
  }
}

// TypeWriter effect widget
class _TypeWriterText extends StatefulWidget {
  final String text;
  final bool isUser;

  const _TypeWriterText({super.key, required this.text, required this.isUser});

  @override
  State<_TypeWriterText> createState() => _TypeWriterTextState();
}

class _TypeWriterTextState extends State<_TypeWriterText> {
  String _displayedText = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    if (_currentIndex < widget.text.length) {
      Future.delayed(const Duration(milliseconds: 20), () {
        if (mounted) {
          setState(() {
            _currentIndex++;
            _displayedText = widget.text.substring(0, _currentIndex);
          });
          _startTyping();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: TextStyle(
        color: widget.isUser ? Colors.black : Colors.white,
        fontSize: 14,
        height: 1.4,
        fontWeight: widget.isUser ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
