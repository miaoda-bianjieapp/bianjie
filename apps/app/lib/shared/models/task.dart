class Task {
  const Task({
    required this.id,
    required this.type,
    required this.title,
    required this.status,
    required this.payload,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      payload: Map<String, dynamic>.from(
        json['payload'] as Map<String, dynamic>? ?? const {},
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String id;
  final String type;
  final String title;
  final String status;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final DateTime updatedAt;
}
