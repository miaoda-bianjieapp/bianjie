import 'package:flutter/material.dart';

import '../../core/utils/icon_mapper.dart';

class PromptSuggestion {
  const PromptSuggestion({
    required this.id,
    required this.text,
    required this.target,
    required this.icon,
    required this.scenario,
  });

  factory PromptSuggestion.fromJson(Map<String, dynamic> json) {
    return PromptSuggestion(
      id: json['id'] as String,
      text: json['text'] as String,
      target: json['target'] as String,
      icon: IconMapper.fromName(json['icon'] as String?),
      scenario: json['scenario'] as String,
    );
  }

  final String id;
  final String text;
  final String target;
  final IconData icon;
  final String scenario;
}
