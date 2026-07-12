import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/snackbar.dart';
import '../../../shared/providers/mock_data_providers.dart';
import '../../../shared/widgets/category_tabs.dart';
import '../../../shared/widgets/input_composer.dart';
import '../../../shared/widgets/section_header.dart';

class AgentsPage extends ConsumerStatefulWidget {
  const AgentsPage({super.key});

  @override
  ConsumerState<AgentsPage> createState() => _AgentsPageState();
}

class _AgentsPageState extends ConsumerState<AgentsPage> {
  final _controller = TextEditingController();
  String _category = '探索';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templates = ref.watch(agentTemplatesProvider);
    final categories = ['探索', '做报告', '写文档', '简历制作', '自媒体创', '市场调研'];
    final visibleTemplates = _category == '探索'
        ? templates
        : templates.where((item) => item.category == _category).toList();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xxl,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => context.push('/history'),
              icon: const Icon(Icons.history),
              label: const Text('历史记录'),
            ),
          ),
          Text('HI，我是边界 AI-Agent 助手',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            children: ['写作', 'PPT', '设计', 'Excel', '网页']
                .map(
                  (tag) => ActionChip(
                    label: Text(tag),
                    onPressed: () {
                      _controller.text = '帮我完成一个$tag任务';
                      showAppSnackBar(context, '已填入任务方向');
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          InputComposer(
            controller: _controller,
            hintText: '给我布置一个任务',
            onSend: () => context.push('/placeholder/agent-task'),
            actions: [
              ComposerActionChip(
                icon: Icons.folder_open,
                label: '素材',
                onTap: () => showAppSnackBar(context, '素材入口占位'),
              ),
              ComposerActionChip(
                icon: Icons.attach_file,
                label: '附件',
                onTap: () => showAppSnackBar(context, '附件入口占位'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: '模板推荐',
            action: '更多',
            onAction: () => showAppSnackBar(context, '更多模板占位'),
          ),
          CategoryTabs(
            items: categories,
            selected: _category,
            onSelected: (value) => setState(() => _category = value),
          ),
          const SizedBox(height: AppSpacing.md),
          ...visibleTemplates.map(
            (template) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ListTile(
                tileColor: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                leading: Icon(template.coverIcon, color: AppColors.primaryBlue),
                title: Text(template.title),
                subtitle: Text(template.description),
                onTap: () => context.push('/agents/template/${template.id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
