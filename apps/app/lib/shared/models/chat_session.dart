class ChatSession {
  const ChatSession({
    required this.id,
    required this.title,
    required this.modelId,
    required this.modelName,
    required this.summary,
    required this.contextPolicy,
    required this.messageCount,
    required this.needsCompression,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      title: json['title'] as String? ?? '新的对话',
      modelId: json['modelId'] as String? ?? '',
      modelName: json['modelName'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      contextPolicy: json['contextPolicy'] as String? ?? '',
      messageCount: json['messageCount'] as int? ?? 0,
      needsCompression: json['needsCompression'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String id;
  final String title;
  final String modelId;
  final String modelName;
  final String summary;
  final String contextPolicy;
  final int messageCount;
  final bool needsCompression;
  final DateTime createdAt;
  final DateTime updatedAt;
}
