import '../models/tool_category.dart';

const mockToolCategories = [
  ToolCategory(
    id: 'recent',
    name: '最近更新',
    count: 4,
    collapsed: false,
    sortOrder: 1,
  ),
  ToolCategory(
    id: 'hot',
    name: '热门推荐',
    count: 5,
    collapsed: false,
    sortOrder: 2,
  ),
  ToolCategory(
    id: 'image',
    name: '图像生成',
    count: 4,
    collapsed: true,
    sortOrder: 3,
  ),
  ToolCategory(
    id: 'ppt',
    name: 'AIPPT',
    count: 3,
    collapsed: true,
    sortOrder: 4,
  ),
  ToolCategory(
    id: 'pdf',
    name: 'PDF 操作',
    count: 3,
    collapsed: true,
    sortOrder: 5,
  ),
  ToolCategory(
    id: 'design',
    name: 'AI 设计',
    count: 3,
    collapsed: true,
    sortOrder: 6,
  ),
  ToolCategory(
    id: 'writing',
    name: '文章创作',
    count: 10,
    collapsed: false,
    sortOrder: 7,
  ),
  ToolCategory(
    id: 'copywriting',
    name: '文案策划',
    count: 5,
    collapsed: false,
    sortOrder: 8,
  ),
  ToolCategory(
    id: 'paper',
    name: '论文辅助',
    count: 4,
    collapsed: false,
    sortOrder: 9,
  ),
  ToolCategory(
    id: 'life',
    name: '生活助手',
    count: 6,
    collapsed: false,
    sortOrder: 10,
  ),
];
