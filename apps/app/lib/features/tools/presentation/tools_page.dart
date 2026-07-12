import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/snackbar.dart';
import '../../../shared/models/tool.dart';
import '../../../shared/models/tool_category.dart';
import '../../../shared/providers/mock_data_providers.dart';
import '../../../shared/widgets/app_search_bar.dart';
import '../../../shared/widgets/tool_grid.dart';

class ToolsPage extends ConsumerStatefulWidget {
  const ToolsPage({super.key});

  @override
  ConsumerState<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends ConsumerState<ToolsPage> {
  final _searchController = TextEditingController();
  final Set<String> _expandedCategoryIds = {'recent', 'hot', 'image'};
  String _keyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(toolCategoriesProvider);
    final tools = ref.watch(toolsProvider);
    final visibleCategories = categories
        .where(
          (category) => ['recent', 'hot', 'image', 'ppt', 'pdf', 'design']
              .contains(category.id),
        )
        .toList();
    final filteredTools = tools
        .where(
          (tool) =>
              _keyword.isEmpty ||
              tool.name.contains(_keyword) ||
              tool.description.contains(_keyword),
        )
        .toList();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          40,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        children: [
          _BrandHeader(),
          const SizedBox(height: AppSpacing.lg),
          AppSearchBar(
            controller: _searchController,
            hintText: '搜索功能或内容',
            onChanged: (value) => setState(() => _keyword = value.trim()),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_keyword.isNotEmpty) ...[
            Text('搜索结果', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            if (filteredTools.isEmpty)
              const _EmptySearchResult()
            else
              ...filteredTools.map(
                (tool) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ToolListTile(
                    tool: tool,
                    onTap: () => context.push(tool.route),
                  ),
                ),
              ),
          ] else
            ...visibleCategories.map(
              (category) => _CategorySection(
                category: category,
                expanded: _expandedCategoryIds.contains(category.id),
                tools: _toolsForCategory(category.id, tools),
                onToggle: () => _toggleCategory(category.id),
              ),
            ),
        ],
      ),
    );
  }

  void _toggleCategory(String id) {
    setState(() {
      if (_expandedCategoryIds.contains(id)) {
        _expandedCategoryIds.remove(id);
      } else {
        _expandedCategoryIds.add(id);
      }
    });
  }

  List<Tool> _toolsForCategory(String categoryId, List<Tool> tools) {
    if (categoryId == 'recent') {
      final sortedTools = [...tools]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return sortedTools.take(4).toList();
    }

    if (categoryId == 'hot') {
      return tools.where((tool) => tool.tags.contains('热门')).take(5).toList();
    }

    return tools.where((tool) => tool.categoryId == categoryId).toList();
  }
}

class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: Icon(Icons.change_history, color: AppColors.primaryBlue),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppConstants.appName,
                  style: Theme.of(context).textTheme.titleLarge),
              const Text(AppConstants.appSubtitle),
            ],
          ),
        ),
        IconButton(
          onPressed: () => showAppSnackBar(context, '分类入口占位'),
          icon: const Icon(Icons.category_outlined),
        ),
        IconButton(
          onPressed: () => showAppSnackBar(context, '更多入口占位'),
          icon: const Icon(Icons.more_horiz),
        ),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.expanded,
    required this.tools,
    required this.onToggle,
  });

  final ToolCategory category;
  final bool expanded;
  final List<Tool> tools;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                        ),
                  ),
                  if (category.id == 'hot') ...[
                    const SizedBox(width: AppSpacing.sm),
                    const _NewBadge(),
                  ],
                  const SizedBox(width: AppSpacing.sm),
                  _CountBadge(count: tools.length),
                  const Spacer(),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeOutCubic,
            crossFadeState:
                expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: ToolPillWrap(
                tools: tools,
                onToolTap: (tool) => context.push(tool.route),
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          '$count个工具',
          textScaler: TextScaler.noScaling,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          'NEW',
          textScaler: TextScaler.noScaling,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Text(
            '没有找到匹配工具',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
