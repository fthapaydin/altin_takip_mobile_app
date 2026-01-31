import 'package:fpdart/fpdart.dart';
import 'package:altin_takip/core/error/failures.dart';
import 'package:altin_takip/features/chat/domain/conversation.dart';
import 'package:altin_takip/features/chat/domain/chat_message.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<Conversation>>> getConversations();

  Future<Either<Failure, List<ChatMessage>>> getMessages(int id);

  Future<Either<Failure, (Conversation, String)>> startConversation(
    String message,
  );

  Future<Either<Failure, String>> sendMessage(int id, String message);
}
