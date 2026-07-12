import 'package:flutter/material.dart';

import '../../core/utils/icon_mapper.dart';

class StockCapability {
  const StockCapability({
    required this.id,
    required this.title,
    required this.prompt,
    required this.icon,
    required this.opensPage,
  });

  factory StockCapability.fromJson(Map<String, dynamic> json) {
    return StockCapability(
      id: json['id'] as String,
      title: json['title'] as String,
      prompt: json['prompt'] as String,
      icon: IconMapper.fromName(json['icon'] as String?),
      opensPage: json['opensPage'] as bool? ?? false,
    );
  }

  final String id;
  final String title;
  final String prompt;
  final IconData icon;
  final bool opensPage;
}
