import 'package:flutter/material.dart';

import '../../core/utils/icon_mapper.dart';

enum ToolExecutionType {
  chat,
  form,
  task,
  external,
  placeholder,
}

class Tool {
  const Tool({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.tab,
    required this.icon,
    required this.tags,
    required this.route,
    required this.enabled,
    required this.sortOrder,
    required this.requiresLogin,
    required this.requiresVip,
    required this.executionType,
    this.config = const {},
  });

  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      categoryId: json['categoryId'] as String,
      tab: json['tab'] as String,
      icon: IconMapper.fromName(json['icon'] as String?),
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((item) => item as String)
          .toList(growable: false),
      route: json['route'] as String,
      enabled: json['enabled'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? 0,
      requiresLogin: json['requiresLogin'] as bool? ?? false,
      requiresVip: json['requiresVip'] as bool? ?? false,
      executionType: ToolExecutionTypeParser.fromJson(
        json['executionType'] as String?,
      ),
      config: Map<String, dynamic>.from(
        json['config'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String tab;
  final IconData icon;
  final List<String> tags;
  final String route;
  final bool enabled;
  final int sortOrder;
  final bool requiresLogin;
  final bool requiresVip;
  final ToolExecutionType executionType;
  final Map<String, dynamic> config;
}

class ToolExecutionTypeParser {
  const ToolExecutionTypeParser._();

  static ToolExecutionType fromJson(String? value) {
    final normalized = value?.toLowerCase();
    return ToolExecutionType.values.firstWhere(
      (type) => type.name == normalized,
      orElse: () => ToolExecutionType.placeholder,
    );
  }
}
