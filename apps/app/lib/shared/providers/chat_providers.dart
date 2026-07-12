import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/chat_repository.dart';
import '../models/chat_attachment.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import 'remote_data_providers.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  if (ref.watch(useRemoteApiProvider)) {
    return RemoteChatRepository(ref.watch(apiClientProvider));
  }
  return const MockChatRepository();
});

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(ref.watch(chatRepositoryProvider));
});

final chatSessionsProvider = FutureProvider((ref) {
  ref.watch(chatControllerProvider);
  return ref.watch(chatRepositoryProvider).listSessions();
});

class ChatState {
  const ChatState({
    this.session,
    this.messages = const [],
    this.isSending = false,
    this.error,
  });

  final ChatSession? session;
  final List<ChatMessage> messages;
  final bool isSending;
  final String? error;

  ChatState copyWith({
    ChatSession? session,
    List<ChatMessage>? messages,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      session: session ?? this.session,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  ChatController(this._repository) : super(const ChatState());

  final ChatRepository _repository;

  Future<void> send({
    required String content,
    required String modelId,
    required String modelName,
    List<ChatAttachment> attachments = const [],
  }) async {
    if (state.isSending) {
      return;
    }
    state = state.copyWith(isSending: true, clearError: true);
    try {
      final session = state.session ??
          await _repository.createSession(
            modelId: modelId,
            modelName: modelName,
          );
      final turn = await _repository.sendMessage(
        session.id,
        content: content,
        modelId: modelId,
        modelName: modelName,
        attachments: attachments,
      );
      state = ChatState(
        session: turn.session,
        messages: [
          ...state.messages,
          turn.userMessage,
          turn.assistantMessage,
        ],
      );
    } catch (error) {
      state = state.copyWith(
        isSending: false,
        error: error.toString(),
      );
    }
  }

  void startNewSession() {
    state = const ChatState();
  }
}
