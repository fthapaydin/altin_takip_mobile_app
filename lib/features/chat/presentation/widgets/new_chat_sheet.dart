import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:altin_takip/features/chat/presentation/chat_notifier.dart';
import 'package:altin_takip/features/chat/presentation/chat_state.dart';
import 'package:altin_takip/features/chat/presentation/chat_room_screen.dart';

/// Modal sheet for initializing a new chat conversation with AI.
class NewChatSheet extends ConsumerStatefulWidget {
  const NewChatSheet({super.key});

  @override
  ConsumerState<NewChatSheet> createState() => _NewChatSheetState();
}

class _NewChatSheetState extends ConsumerState<NewChatSheet> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24, right: 24, top: 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.surface.withValues(alpha: 0.98),
            AppTheme.background.withValues(alpha: 0.98),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: AppTheme.gold.withValues(alpha: 0.2), width: 2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(24),
          _buildAIHeader(),
          const Gap(20),
          const Text(
            'Yeni Sohbet Başlat',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400, letterSpacing: -0.5),
          ),
          const Gap(8),
          Text(
            'Portföyünüz hakkında istediğiniz soruyu sorun',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
          const Gap(32),
          _buildInputField(),
          const Gap(20),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildAIHeader() {
    return Container(
      width: 72, height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.gold.withValues(alpha: 0.2), AppTheme.gold.withValues(alpha: 0.05)],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4), width: 2),
        boxShadow: [BoxShadow(color: AppTheme.gold.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: const Icon(Iconsax.magic_star, color: AppTheme.gold, size: 36),
    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut);
  }

  Widget _buildInputField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.5),
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
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.gold, AppTheme.gold.withValues(alpha: 0.85)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppTheme.gold.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _isLoading ? null : _submitPrompt,
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Gönder', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 15)),
                        Gap(10),
                        Icon(Iconsax.send_1, color: Colors.black, size: 20),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitPrompt() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    final message = _controller.text.trim();
    final notifier = ref.read(chatRoomProvider.notifier);
    final historyNotifier = ref.read(chatHistoryProvider.notifier);

    await notifier.startNewChat(message);
    if (!mounted) return;

    setState(() => _isLoading = false);
    final chatState = ref.read(chatRoomProvider);
    dev.log('Chat state: ${chatState.runtimeType}');

    Navigator.pop(context);

    if (chatState is ChatRoomLoaded) {
      dev.log('Navigating to chat room');
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatRoomScreen()));
    } else if (chatState is ChatRoomError) {
      dev.log('Showing error: ${chatState.message}');
      AppNotification.show(context, message: chatState.message, type: NotificationType.error);
      historyNotifier.loadConversations(isRefreshing: true);
    }
  }
}
