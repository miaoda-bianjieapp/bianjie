import 'package:flutter/material.dart';

import '../models/agent_template.dart';

const mockAgentTemplates = [
  AgentTemplate(
    id: 'resume-demo',
    title: '简历优化助手',
    coverIcon: Icons.badge_outlined,
    category: '简历制作',
    prompt: '帮我优化一份面向产品经理岗位的简历。',
    description: '整理经历亮点，改写项目表述，生成投递建议。',
  ),
  AgentTemplate(
    id: 'training-plan',
    title: '新员工培训方案',
    coverIcon: Icons.school_outlined,
    category: '做报告',
    prompt: '为 20 人团队设计一周新员工培训方案。',
    description: '输出培训目标、日程安排、材料清单和验收方式。',
  ),
  AgentTemplate(
    id: 'market-research',
    title: '养老服务市场调研',
    coverIcon: Icons.travel_explore_outlined,
    category: '市场调研',
    prompt: '帮我做一份养老服务市场调研框架。',
    description: '覆盖行业规模、用户画像、竞品维度和访谈问题。',
  ),
  AgentTemplate(
    id: 'web-brief',
    title: '网页需求梳理',
    coverIcon: Icons.web_outlined,
    category: '写文档',
    prompt: '把我的想法整理成网页产品需求文档。',
    description: '产出页面结构、模块说明、交互流程和验收标准。',
  ),
];
