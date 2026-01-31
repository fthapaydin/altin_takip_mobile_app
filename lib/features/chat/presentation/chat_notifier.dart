import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/features/chat/domain/chat_repository.dart';
import 'package:altin_takip/features/chat/presentation/chat_state.dart';
import 'package:altin_takip/features/chat/domain/chat_message.dart';
import 'package:altin_takip/features/chat/domain/conversation.dart';

// --- Providers ---

final chatHistoryProvider =
    NotifierProvider<ChatHistoryNotifier, ChatHistoryState>(
      ChatHistoryNotifier.new,
    );

final chatRoomProvider = NotifierProvider<ChatRoomNotifier, ChatRoomState>(
  ChatRoomNotifier.new,
);

// --- History Notifier ---

class ChatHistoryNotifier extends Notifier<ChatHistoryState> {
  late ChatRepository _chatRepository;

  @override
  ChatHistoryState build() {
    _chatRepository = sl<ChatRepository>();
    return ChatHistoryInitial();
  }

  Future<void> loadConversations({bool isRefreshing = false}) async {
    dev.log('Loading conversations (refreshing: $isRefreshing)');
    if (state is! ChatHistoryLoaded || isRefreshing) {
      if (!isRefreshing) state = ChatHistoryLoading();
    }

    final result = await _chatRepository.getConversations();

    result.fold(
      (failure) {
        dev.log('Load conversations error: ${failure.message}');
        state = ChatHistoryError(failure.message);
      },
      (conversations) {
        dev.log('Loaded ${conversations.length} conversations');
        state = ChatHistoryLoaded(
          conversations: conversations,
          isRefreshing: false,
        );
      },
    );
  }
}

// --- Room Notifier ---

class ChatRoomNotifier extends Notifier<ChatRoomState> {
  late ChatRepository _chatRepository;

  @override
  ChatRoomState build() {
    _chatRepository = sl<ChatRepository>();
    return ChatRoomInitial();
  }

  void setConversation(Conversation conversation) {
    state = ChatRoomLoaded(conversation: conversation, messages: const []);
    loadMessages(conversation.id);
  }

  Future<void> loadMessages(int conversationId) async {
    final result = await _chatRepository.getMessages(conversationId);

    result.fold(
      (failure) {
        if (state is ChatRoomLoaded) {
          state = (state as ChatRoomLoaded).copyWith(error: failure.message);
        } else {
          state = ChatRoomError(failure.message);
        }
      },
      (messages) {
        if (state is ChatRoomLoaded) {
          state = (state as ChatRoomLoaded).copyWith(messages: messages);
        }
      },
    );
  }

  Future<void> startNewChat(String firstMessage) async {
    state = ChatRoomLoading();

    final result = await _chatRepository.startConversation(firstMessage);

    result.fold((failure) => state = ChatRoomError(failure.message), (data) {
      final (conversation, aiResponse) = data;
      state = ChatRoomLoaded(
        conversation: conversation,
        messages: [
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch,
            role: 'user',
            content: firstMessage,
            isToolCall: false,
          ),
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch + 1,
            role: 'model',
            content: aiResponse,
            isToolCall: false,
          ),
        ],
      );
      // Refresh history in background
      ref
          .read(chatHistoryProvider.notifier)
          .loadConversations(isRefreshing: true);
    });
  }

  Future<void> sendMessage(String text) async {
    final currentState = state;
    if (currentState is! ChatRoomLoaded) return;

    dev.log('User sending message: $text');
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      role: 'user',
      content: text,
      isToolCall: false,
    );

    state = currentState.copyWith(
      messages: [...currentState.messages, userMessage],
      isSending: true,
      error: null,
    );

    final result = await _chatRepository.sendMessage(
      currentState.conversation.id,
      text,
    );

    result.fold(
      (failure) {
        dev.log('Send message error in notifier: ${failure.message}');
        state = (state as ChatRoomLoaded).copyWith(
          isSending: false,
          error: failure.message,
        );
      },
      (aiResponse) {
        dev.log('Received AI response in notifier: $aiResponse');
        final modelMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch,
          role: 'model',
          content: aiResponse,
          isToolCall: false,
        );
        state = (state as ChatRoomLoaded).copyWith(
          messages: [...(state as ChatRoomLoaded).messages, modelMessage],
          isSending: false,
        );
      },
    );
  }
}
