import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/snackbar.dart';
import '../../../shared/providers/mock_data_providers.dart';

class AgentTemplatePage extends ConsumerWidget {
  const AgentTemplatePage({
    required this.templateId,
    super.key,
  });

  final String templateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(agentTemplatesProvider);
    final template = templates.firstWhere(
      (item) => item.id == templateId,
      orElse: () => templates.first,
    );

    return Scaffold(
      appBar: AppBar(title: Text(template.title)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    template.coverIcon,
                    color: AppColors.primaryBlue,
                    size: 40,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    template.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(template.description),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    template.prompt,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton.icon(
                    onPressed: () => showAppSnackBar(context, '已套用模板到任务框'),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('一键使用'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
