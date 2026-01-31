import 'package:altin_takip/features/chat/domain/chat_message.dart';

class ChatMessageDto extends ChatMessage {
  const ChatMessageDto({
    required super.id,
    required super.role,
    required super.content,
    required super.isToolCall,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      id: json['id'],
      role: json['role'],
      content: json['content'],
      isToolCall: json['is_tool_call'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'is_tool_call': isToolCall,
    };
  }
}
