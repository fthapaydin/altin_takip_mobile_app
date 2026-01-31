import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final int id;
  final String role; // "user" or "model"
  final String content;
  final bool isToolCall;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.isToolCall,
  });

  bool get isUser => role == 'user';
  bool get isModel => role == 'model';

  @override
  List<Object?> get props => [id, role, content, isToolCall];
}
