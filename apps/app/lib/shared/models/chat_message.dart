import 'chat_attachment.dart';

enum ChatRole {
  user,
  assistant,
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.messageType,
    required this.content,
    required this.modelId,
    required this.modelName,
    required this.attachments,
    required this.tokenEstimate,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      role: ChatRoleParser.fromJson(json['role'] as String?),
      messageType: json['messageType'] as String? ?? 'TEXT',
      content: json['content'] as String,
      modelId: json['modelId'] as String? ?? '',
      modelName: json['modelName'] as String? ?? '',
      attachments: (json['attachments'] as List<dynamic>? ?? const [])
          .map((item) => ChatAttachment.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      tokenEstimate: json['tokenEstimate'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String sessionId;
  final ChatRole role;
  final String messageType;
  final String content;
  final String modelId;
  final String modelName;
  final List<ChatAttachment> attachments;
  final int tokenEstimate;
  final DateTime createdAt;
}

class ChatRoleParser {
  const ChatRoleParser._();

  static ChatRole fromJson(String? value) {
    final normalized = value?.toLowerCase();
    return ChatRole.values.firstWhere(
      (role) => role.name == normalized,
      orElse: () => ChatRole.assistant,
    );
  }
}
