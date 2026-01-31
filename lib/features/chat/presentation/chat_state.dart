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
  const ChatHistoryLoaded({
    required this.conversations,
    this.isRefreshing = false,
  });
  @override
  List<Object?> get props => [conversations, isRefreshing];
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
  final String? error;

  const ChatRoomLoaded({
    required this.conversation,
    required this.messages,
    this.isSending = false,
    this.error,
  });

  ChatRoomLoaded copyWith({
    Conversation? conversation,
    List<ChatMessage>? messages,
    bool? isSending,
    String? error,
  }) {
    return ChatRoomLoaded(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }

  @override
  List<Object?> get props => [conversation, messages, isSending, error];
}

class ChatRoomError extends ChatRoomState {
  final String message;
  const ChatRoomError(this.message);
  @override
  List<Object?> get props => [message];
}
