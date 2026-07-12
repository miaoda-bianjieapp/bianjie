class ChatAttachment {
  const ChatAttachment({
    required this.id,
    required this.name,
    required this.kind,
    required this.type,
    required this.mimeType,
    required this.size,
    required this.status,
    this.url,
    this.base64Data,
  });

  factory ChatAttachment.fromJson(Map<String, dynamic> json) {
    return ChatAttachment(
      id: json['id'] as String,
      name: json['name'] as String,
      kind: json['kind'] as String? ?? 'FILE',
      type: json['type'] as String,
      mimeType: json['mimeType'] as String? ?? json['type'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      status: json['status'] as String? ?? 'PENDING_UPLOAD',
      url: json['url'] as String?,
      base64Data: json['base64Data'] as String?,
    );
  }

  final String id;
  final String name;
  final String kind;
  final String type;
  final String mimeType;
  final int size;
  final String status;
  final String? url;
  final String? base64Data;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'kind': kind,
      'type': type,
      'mimeType': mimeType,
      'size': size,
      'status': status,
      if (url != null) 'url': url,
      if (base64Data != null) 'base64Data': base64Data,
    };
  }
}
