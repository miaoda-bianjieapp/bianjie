import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/snackbar.dart';
import '../../../shared/providers/mock_data_providers.dart';
import '../../../shared/widgets/app_search_bar.dart';
import '../../../shared/widgets/category_tabs.dart';
import '../../../shared/widgets/model_badge.dart';
import '../../../shared/widgets/tool_grid.dart';

class WritingPage extends ConsumerStatefulWidget {
  const WritingPage({super.key});

  @override
  ConsumerState<WritingPage> createState() => _WritingPageState();
}

class _WritingPageState extends ConsumerState<WritingPage> {
  final _searchController = TextEditingController();
  String _category = '全部';
  String _keyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allTools = ref
        .watch(toolsProvider)
        .where((tool) => tool.tab == 'writing')
        .toList();
    final selectedModel = ref.watch(selectedModelProvider);
    final categories = ['全部', '文章创作', '文案策划', '论文辅助', '生活助手'];
    final categoryMap = {
      '文章创作': 'writing',
      '文案策划': 'copywriting',
      '论文辅助': 'paper',
      '生活助手': 'life',
    };
    final tools = allTools.where((tool) {
      final matchCategory =
          _category == '全部' || tool.categoryId == categoryMap[_category];
      final matchKeyword = _keyword.isEmpty ||
          tool.name.contains(_keyword) ||
          tool.description.contains(_keyword);
      return matchCategory && matchKeyword;
    }).toList();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          40,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: Icon(
                    Icons.edit_note,
                    color: AppColors.accentOrange,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  '边界 AI 写作',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: () => showAppSnackBar(context, '搜索入口已展开'),
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ModelBadge(
            label: selectedModel,
            onTap: () => context.push('/models'),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSearchBar(
            controller: _searchController,
            hintText: '搜索写作工具',
            onChanged: (value) => setState(() => _keyword = value.trim()),
          ),
          const SizedBox(height: AppSpacing.lg),
          CategoryTabs(
            items: categories,
            selected: _category,
            onSelected: (value) => setState(() => _category = value),
          ),
          const SizedBox(height: AppSpacing.lg),
          ToolPillWrap(
            tools: tools,
            onToolTap: (tool) => context.push(tool.route),
          ),
        ],
      ),
    );
  }
}
