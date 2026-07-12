import 'package:flutter/material.dart';

import '../models/prompt_suggestion.dart';

const mockPrompts = [
  PromptSuggestion(
    id: 'prompt-design',
    text: '一秒生成设计图',
    target: '/tool/design-image',
    icon: Icons.image_outlined,
    scenario: 'home',
  ),
  PromptSuggestion(
    id: 'prompt-video',
    text: '零基础制作爆款短视频',
    target: '/tool/video-script',
    icon: Icons.movie_creation_outlined,
    scenario: 'home',
  ),
  PromptSuggestion(
    id: 'prompt-ppt',
    text: '帮我生成一份教学 PPT',
    target: '/tool/teaching-ppt',
    icon: Icons.co_present_outlined,
    scenario: 'home',
  ),
  PromptSuggestion(
    id: 'prompt-stock',
    text: '分析某股票最新财报与估值',
    target: '/stock/analyze-stock',
    icon: Icons.query_stats,
    scenario: 'stock',
  ),
];
