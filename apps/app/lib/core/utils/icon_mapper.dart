import 'package:flutter/material.dart';

class IconMapper {
  const IconMapper._();

  static IconData fromName(String? name) {
    return switch (name) {
      'article' => Icons.article_outlined,
      'badge' => Icons.badge_outlined,
      'brush' => Icons.brush_outlined,
      'check' => Icons.fact_check_outlined,
      'diamond' => Icons.diamond_outlined,
      'document' => Icons.edit_document,
      'filter' => Icons.filter_alt_outlined,
      'face' => Icons.face_retouching_natural_outlined,
      'heart' => Icons.favorite_border,
      'image' => Icons.image_outlined,
      'magic' => Icons.auto_fix_high_outlined,
      'more' => Icons.more_horiz,
      'movie' => Icons.movie_creation_outlined,
      'news' => Icons.newspaper_outlined,
      'outline' => Icons.format_list_numbered_outlined,
      'palette' => Icons.palette_outlined,
      'pdf' => Icons.picture_as_pdf_outlined,
      'ppt' => Icons.co_present_outlined,
      'public' => Icons.public,
      'query-stats' => Icons.query_stats,
      'research' => Icons.travel_explore_outlined,
      'rewrite' => Icons.sync_alt_outlined,
      'school' => Icons.school_outlined,
      'shirt' => Icons.checkroom_outlined,
      'sparkle' => Icons.auto_fix_high_outlined,
      'stock' => Icons.show_chart,
      'timeline' => Icons.timeline,
      'web' => Icons.web_outlined,
      _ => Icons.extension_outlined,
    };
  }
}
