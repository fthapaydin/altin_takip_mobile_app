import 'package:equatable/equatable.dart';
import 'package:altin_takip/features/chat/domain/conversation.dart';
import 'package:altin_takip/features/chat/domain/chat_message.dart';

// --- History State ---
sealed class ChatHistoryState extends Equatable {
  const ChatHistoryState();
  @override
  List<Object?> get props => [];
}

class ChatHistoryInitial extends ChatHistoryState {}

class ChatHistoryLoading extends ChatHistoryState {}

class ChatHistoryLoaded extends ChatHistoryState {
  final List<Conversation> conversations;
  final bool isRefreshing;
  final bool isDeleting;

  const ChatHistoryLoaded({
    required this.conversations,
    this.isRefreshing = false,
    this.isDeleting = false,
  });

  ChatHistoryLoaded copyWith({
    List<Conversation>? conversations,
    bool? isRefreshing,
    bool? isDeleting,
  }) {
    return ChatHistoryLoaded(
      conversations: conversations ?? this.conversations,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  @override
  List<Object?> get props => [conversations, isRefreshing, isDeleting];
}

class ChatHistoryError extends ChatHistoryState {
  final String message;
  const ChatHistoryError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- Room State ---
sealed class ChatRoomState extends Equatable {
  const ChatRoomState();
  @override
  List<Object?> get props => [];
}

class ChatRoomInitial extends ChatRoomState {}

class ChatRoomLoading extends ChatRoomState {}

class ChatRoomLoaded extends ChatRoomState {
  final Conversation conversation;
  final List<ChatMessage> messages;
  final bool isSending;
  final int? lastAddedMessageId;
  final String? error;

  const ChatRoomLoaded({
    required this.conversation,
    required this.messages,
    this.isSending = false,
    this.lastAddedMessageId,
    this.error,
  });

  ChatRoomLoaded copyWith({
    Conversation? conversation,
    List<ChatMessage>? messages,
    bool? isSending,
    int? lastAddedMessageId,
    String? error,
  }) {
    return ChatRoomLoaded(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      lastAddedMessageId: lastAddedMessageId ?? this.lastAddedMessageId,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    conversation,
    messages,
    isSending,
    lastAddedMessageId,
    error,
  ];
}

class ChatRoomError extends ChatRoomState {
  final String message;
  const ChatRoomError(this.message);
  @override
  List<Object?> get props => [message];
}
