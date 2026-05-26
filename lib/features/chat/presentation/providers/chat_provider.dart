import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/constants.dart';

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.createdAt,
  });

  final String text;
  final bool isUser;
  final DateTime createdAt;
}

class ChatState {
  const ChatState({
    required this.messages,
    this.isSending = false,
    this.error,
  });

  final List<ChatMessage> messages;
  final bool isSending;
  final String? error;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref.watch(dioProvider));
});

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._dio)
      : super(
          ChatState(
            messages: [
              ChatMessage(
                text:
                    'Ask me about fighters, rankings, records, or upcoming UFC events.',
                isUser: false,
                createdAt: DateTime.now(),
              ),
            ],
          ),
        );

  final Dio _dio;

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return;

    final userMessage = ChatMessage(
      text: trimmed,
      isUser: true,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isSending: true,
      error: null,
    );

    try {
      final response = await _dio.post(
        ApiConstants.chat,
        data: {'message': trimmed},
      );

      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            text: _extractReply(response.data),
            isUser: false,
            createdAt: DateTime.now(),
          ),
        ],
        isSending: false,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.response?.data?.toString() ?? e.message ?? 'Chat failed',
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  String _extractReply(dynamic data) {
    if (data is String) return data;

    if (data is Map<String, dynamic>) {
      for (final key in [
        'reply',
        'response',
        'answer',
        'message',
        'content',
        'text',
      ]) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) {
          return value;
        }
      }

      final nestedData = data['data'];
      if (nestedData != null) {
        return _extractReply(nestedData);
      }
    }

    return 'I received a response, but could not read the answer format.';
  }
}
