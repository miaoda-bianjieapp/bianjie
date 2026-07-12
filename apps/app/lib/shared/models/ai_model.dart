class AiModel {
  const AiModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isDefault,
  });

  final String id;
  final String name;
  final String description;
  final bool isDefault;

  factory AiModel.fromJson(Map<String, dynamic> json) {
    return AiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      isDefault:
          json['defaultModel'] as bool? ?? json['isDefault'] as bool? ?? false,
    );
  }
}
