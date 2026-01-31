import 'package:altin_takip/features/chat/domain/conversation.dart';

class ConversationDto extends Conversation {
  const ConversationDto({
    required super.id,
    required super.title,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ConversationDto.fromJson(Map<String, dynamic> json) {
    return ConversationDto(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
