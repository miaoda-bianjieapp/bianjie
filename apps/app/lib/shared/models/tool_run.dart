class ToolRun {
  const ToolRun({
    required this.id,
    required this.toolId,
    required this.status,
    required this.input,
    required this.parameters,
    required this.output,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ToolRun.fromJson(Map<String, dynamic> json) {
    return ToolRun(
      id: json['id'] as String,
      toolId: json['toolId'] as String,
      status: json['status'] as String,
      input: json['input'] as String,
      parameters: Map<String, dynamic>.from(
        json['parameters'] as Map<String, dynamic>? ?? const {},
      ),
      output: Map<String, dynamic>.from(
        json['output'] as Map<String, dynamic>? ?? const {},
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String id;
  final String toolId;
  final String status;
  final String input;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> output;
  final DateTime createdAt;
  final DateTime updatedAt;
}
