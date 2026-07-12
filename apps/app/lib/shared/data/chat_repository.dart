import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../models/chat_attachment.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

class ChatTurn {
  const ChatTurn({
    required this.session,
    required this.userMessage,
    required this.assistantMessage,
  });

  factory ChatTurn.fromJson(Map<String, dynamic> json) {
    return ChatTurn(
      session: ChatSession.fromJson(json['session'] as Map<String, dynamic>),
      userMessage:
          ChatMessage.fromJson(json['userMessage'] as Map<String, dynamic>),
      assistantMessage: ChatMessage.fromJson(
        json['assistantMessage'] as Map<String, dynamic>,
      ),
    );
  }

  final ChatSession session;
  final ChatMessage userMessage;
  final ChatMessage assistantMessage;
}

abstract class ChatRepository {
  Future<List<ChatSession>> listSessions();

  Future<ChatSession> createSession({
    required String modelId,
    required String modelName,
  });

  Future<List<ChatMessage>> getMessages(String sessionId);

  Future<ChatTurn> sendMessage(
    String sessionId, {
    required String content,
    required String modelId,
    required String modelName,
    List<ChatAttachment> attachments = const [],
  });
}

class MockChatRepository implements ChatRepository {
  const MockChatRepository();

  @override
  Future<List<ChatSession>> listSessions() async {
    return const [];
  }

  @override
  Future<ChatSession> createSession({
    required String modelId,
    required String modelName,
  }) async {
    final now = DateTime.now();
    return ChatSession(
      id: 'local-chat-${now.microsecondsSinceEpoch}',
      title: '新的对话',
      modelId: modelId,
      modelName: modelName,
      summary: '',
      contextPolicy: 'summary_plus_recent_messages',
      messageCount: 0,
      needsCompression: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<List<ChatMessage>> getMessages(String sessionId) async {
    return const [];
  }

  @override
  Future<ChatTurn> sendMessage(
    String sessionId, {
    required String content,
    required String modelId,
    required String modelName,
    List<ChatAttachment> attachments = const [],
  }) async {
    final now = DateTime.now();
    final session = ChatSession(
      id: sessionId,
      title: content.length <= 24 ? content : '${content.substring(0, 24)}...',
      modelId: modelId,
      modelName: modelName,
      summary: '',
      contextPolicy: 'summary_plus_recent_messages',
      messageCount: 2,
      needsCompression: false,
      createdAt: now,
      updatedAt: now,
    );
    final userMessage = ChatMessage(
      id: 'local-user-${now.microsecondsSinceEpoch}',
      sessionId: sessionId,
      role: ChatRole.user,
      messageType: attachments.any((item) => item.kind == 'IMAGE')
          ? 'IMAGE_QUESTION'
          : 'TEXT',
      content: content,
      modelId: modelId,
      modelName: modelName,
      attachments: attachments,
      tokenEstimate: content.length ~/ 2,
      createdAt: now,
    );
    final assistantMessage = ChatMessage(
      id: 'local-assistant-${now.microsecondsSinceEpoch}',
      sessionId: sessionId,
      role: ChatRole.assistant,
      messageType: 'TEXT',
      content: '已收到你的问题，当前使用 $modelName 生成本地 mock 回复。后续会替换为真实 AI Gateway。',
      modelId: modelId,
      modelName: modelName,
      attachments: const [],
      tokenEstimate: 80,
      createdAt: now.add(const Duration(milliseconds: 1)),
    );
    return ChatTurn(
      session: session,
      userMessage: userMessage,
      assistantMessage: assistantMessage,
    );
  }
}

class RemoteChatRepository implements ChatRepository {
  RemoteChatRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ChatSession>> listSessions() async {
    final response = await _apiClient.dio.get<Object?>('/chat/sessions');
    final items = _readData(response.data) as List<dynamic>;
    return items
        .map((item) => ChatSession.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<ChatSession> createSession({
    required String modelId,
    required String modelName,
  }) async {
    final response = await _apiClient.dio.post<Object?>(
      '/chat/sessions',
      data: {
        'modelId': modelId,
        'modelName': modelName,
        'source': 'flutter-home',
      },
    );
    return ChatSession.fromJson(_readMap(response.data));
  }

  @override
  Future<List<ChatMessage>> getMessages(String sessionId) async {
    final response = await _apiClient.dio.get<Object?>(
      '/chat/sessions/$sessionId/messages',
    );
    final items = _readData(response.data) as List<dynamic>;
    return items
        .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<ChatTurn> sendMessage(
    String sessionId, {
    required String content,
    required String modelId,
    required String modelName,
    List<ChatAttachment> attachments = const [],
  }) async {
    try {
      final response = await _apiClient.dio.post<Object?>(
        '/chat/sessions/$sessionId/messages',
        data: {
          'content': content,
          'messageType': attachments.any((item) => item.kind == 'IMAGE')
              ? 'IMAGE_QUESTION'
              : 'TEXT',
          'modelId': modelId,
          'modelName': modelName,
          'attachments': attachments.map((item) => item.toJson()).toList(),
          'source': 'flutter-home',
        },
      );
      return ChatTurn.fromJson(_readMap(response.data));
    } on DioException catch (error) {
      throw ChatRepositoryException('NETWORK_ERROR', _dioMessage(error));
    }
  }

  Map<String, dynamic> _readMap(Object? responseData) {
    return _readData(responseData) as Map<String, dynamic>;
  }

  Object? _readData(Object? responseData) {
    final envelope = responseData as Map<String, dynamic>;
    if (envelope['success'] != true) {
      throw ChatRepositoryException(
        envelope['code'] as String? ?? 'REMOTE_ERROR',
        envelope['message'] as String? ?? 'Remote API request failed',
      );
    }
    return envelope['data'];
  }
}

class ChatRepositoryException implements Exception {
  ChatRepositoryException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}

String _dioMessage(DioException error) {
  if (error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.connectionTimeout) {
    return 'AI 图片分析耗时较长，请稍后重试或换一张更小的图片。';
  }
  final statusCode = error.response?.statusCode;
  if (statusCode != null && statusCode >= 500) {
    return '服务器处理失败，请稍后重试。';
  }
  return '网络请求失败，请检查后端服务和手机网络连接。';
}
