class ToolCategory {
  const ToolCategory({
    required this.id,
    required this.name,
    required this.count,
    required this.collapsed,
    required this.sortOrder,
    this.parentId,
  });

  final String id;
  final String name;
  final int count;
  final String? parentId;
  final bool collapsed;
  final int sortOrder;

  factory ToolCategory.fromJson(Map<String, dynamic> json) {
    return ToolCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      count: json['count'] as int? ?? 0,
      parentId: json['parentId'] as String?,
      collapsed: json['collapsed'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}
