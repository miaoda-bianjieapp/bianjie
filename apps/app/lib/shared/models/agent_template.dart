import 'package:flutter/material.dart';

import '../../core/utils/icon_mapper.dart';

class AgentTemplate {
  const AgentTemplate({
    required this.id,
    required this.title,
    required this.coverIcon,
    required this.category,
    required this.prompt,
    required this.description,
  });

  factory AgentTemplate.fromJson(Map<String, dynamic> json) {
    return AgentTemplate(
      id: json['id'] as String,
      title: json['title'] as String,
      coverIcon: IconMapper.fromName(json['coverIcon'] as String?),
      category: json['category'] as String,
      prompt: json['prompt'] as String,
      description: json['description'] as String,
    );
  }

  final String id;
  final String title;
  final IconData coverIcon;
  final String category;
  final String prompt;
  final String description;
}
