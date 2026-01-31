import 'package:dio/dio.dart';
import 'dart:developer' as dev;
import 'package:fpdart/fpdart.dart';
import 'package:altin_takip/core/error/failures.dart';
import 'package:altin_takip/core/network/dio_client.dart';
import 'package:altin_takip/core/network/network_exception_handler.dart';
import 'package:altin_takip/features/chat/data/conversation_dto.dart';
import 'package:altin_takip/features/chat/data/chat_message_dto.dart';
import 'package:altin_takip/features/chat/domain/conversation.dart';
import 'package:altin_takip/features/chat/domain/chat_message.dart';
import 'package:altin_takip/features/chat/domain/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final DioClient _dioClient;

  ChatRepositoryImpl(this._dioClient);

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    try {
      final response = await _dioClient.dio.get('chat/conversations');
      final dynamic responseData = response.data;

      List data;
      if (responseData is List) {
        data = responseData;
      } else if (responseData is Map<String, dynamic>) {
        data = responseData['conversations'] ?? responseData['data'] ?? [];
      } else {
        data = [];
      }

      final conversations = data
          .map((json) => ConversationDto.fromJson(json))
          .toList();
      return Right(conversations);
    } catch (e) {
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(int id) async {
    try {
      final response = await _dioClient.dio.get('chat/conversations/$id');
      final dynamic responseData = response.data;

      List data;
      if (responseData is List) {
        data = responseData;
      } else if (responseData is Map<String, dynamic>) {
        data = responseData['messages'] ?? responseData['data'] ?? [];
      } else {
        data = [];
      }

      final messages = data
          .map((json) => ChatMessageDto.fromJson(json))
          .toList();
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, (Conversation, String)>> startConversation(
    String message,
  ) async {
    try {
      dev.log('Starting conversation with message: $message');
      final response = await _dioClient.dio.post(
        'chat/conversations',
        data: {'message': message},
      );
      dev.log('Start conversation response: ${response.data}');
      final conversation = ConversationDto.fromJson(
        response.data['conversation'],
      );
      final aiResponse = response.data['response'] as String;
      return Right((conversation, aiResponse));
    } catch (e) {
      if (e is DioException) {
        dev.log('Start conversation error body: ${e.response?.data}');

        // Special handling for 429 errors - conversation might be created
        if (e.response?.statusCode == 429 && e.response?.data != null) {
          try {
            final data = e.response!.data;
            // Try to extract conversation if it exists
            if (data is Map<String, dynamic> && data['conversation'] != null) {
              final conversation = ConversationDto.fromJson(
                data['conversation'],
              );
              final errorMessage =
                  data['error']?.toString() ??
                  data['message']?.toString() ??
                  'Yapay zeka servisi şu anda meşgul. Lütfen biraz sonra tekrar deneyin.';
              dev.log(
                'Extracted conversation from 429 error, showing error as message',
              );
              return Right((conversation, errorMessage));
            }
          } catch (parseError) {
            dev.log(
              'Failed to parse conversation from error response: $parseError',
            );
          }
        }
      }
      dev.log('Start conversation error: $e');
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, String>> sendMessage(int id, String message) async {
    try {
      dev.log('Sending message to conversation $id: $message');
      final response = await _dioClient.dio.post(
        'chat/conversations/$id/messages',
        data: {'message': message},
      );
      dev.log('Send message response: ${response.data}');
      final aiResponse = response.data['response'] as String;
      return Right(aiResponse);
    } catch (e) {
      if (e is DioException) {
        final errorData = e.response?.data;
        dev.log('Send message error body: $errorData');

        // If backend provided a specific error message, return it as a model response
        if (errorData is Map<String, dynamic> &&
            errorData.containsKey('error')) {
          return Right(errorData['error'] as String);
        }
      }
      dev.log('Send message error: $e');
      return Left(ServerFailure(NetworkExceptionHandler.getErrorMessage(e)));
    }
  }
}
