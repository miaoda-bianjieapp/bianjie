import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snackbar.dart';
import '../models/chat_attachment.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../models/tool_run.dart';
import '../providers/chat_providers.dart';
import '../providers/mock_data_providers.dart';
import '../providers/tool_execution_providers.dart';
import 'artifact_attachment_card.dart';
import 'copy_icon_button.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsState = ref.watch(chatSessionsProvider);
    final toolRunsState = ref.watch(toolRunsHistoryProvider);
    final sessions = sessionsState.valueOrNull ?? const [];
    final toolRuns = toolRunsState.valueOrNull ?? const [];
    final hasRecords = sessions.isNotEmpty || toolRuns.isNotEmpty;
    final isLoading = sessionsState.isLoading || toolRunsState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('历史记录')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(chatSessionsProvider);
          ref.invalidate(toolRunsHistoryProvider);
          try {
            await Future.wait([
              ref.read(chatSessionsProvider.future),
              ref.read(toolRunsHistoryProvider.future),
            ]);
          } catch (_) {
            // Individual loading errors are rendered in the list below.
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (isLoading) ...[
              const LinearProgressIndicator(minHeight: 3),
              const SizedBox(height: AppSpacing.md),
            ],
            if (sessionsState.hasError) ...[
              _HistoryLoadError(
                label: '对话记录加载失败',
                onRetry: () => ref.invalidate(chatSessionsProvider),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (toolRunsState.hasError) ...[
              _HistoryLoadError(
                label: '工具调用记录加载失败',
                onRetry: () => ref.invalidate(toolRunsHistoryProvider),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (!hasRecords &&
                !isLoading &&
                !sessionsState.hasError &&
                !toolRunsState.hasError)
              const _EmptyHistory(),
            if (sessions.isNotEmpty) ...[
              _HistorySectionTitle(
                title: '对话记录',
                count: sessions.length,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...sessions.map(
                (session) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _ChatHistoryTile(
                    session: session,
                    onTap: () => _showChatDetail(context, ref, session),
                  ),
                ),
              ),
            ],
            if (toolRuns.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _HistorySectionTitle(
                title: '工具调用',
                count: toolRuns.length,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...toolRuns.map(
                (run) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _ToolRunHistoryTile(
                    run: run,
                    onTap: () => _showToolRunDetail(context, run),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showChatDetail(
    BuildContext context,
    WidgetRef ref,
    ChatSession session,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return _HistorySheet(
          title: session.title,
          child: FutureBuilder<List<ChatMessage>>(
            future: ref.read(chatRepositoryProvider).getMessages(session.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final messages = snapshot.data!;
              if (messages.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Text('暂无消息'),
                );
              }
              return Column(
                children: messages
                    .map(
                      (message) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _HistoryMessage(message: message),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        );
      },
    );
  }

  void _showToolRunDetail(BuildContext context, ToolRun run) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return _HistorySheet(
          title: '工具调用详情',
          child: _ToolRunDetail(run: run),
        );
      },
    );
  }
}

class _HistorySectionTitle extends StatelessWidget {
  const _HistorySectionTitle({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(width: AppSpacing.sm),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.chip,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              '$count条',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryLoadError extends StatelessWidget {
  const _HistoryLoadError({
    required this.label,
    required this.onRetry,
  });

  final String label;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(label)),
        IconButton(
          tooltip: '重试',
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}

class _ChatHistoryTile extends StatelessWidget {
  const _ChatHistoryTile({
    required this.session,
    required this.onTap,
  });

  final ChatSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      leading: Icon(Icons.chat_outlined, color: AppColors.primaryBlue),
      title: Text(session.title),
      subtitle: Text('${session.modelName} · ${session.messageCount} 条消息'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _ToolRunHistoryTile extends StatelessWidget {
  const _ToolRunHistoryTile({
    required this.run,
    required this.onTap,
  });

  final ToolRun run;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      leading: Icon(Icons.auto_awesome, color: AppColors.primaryBlue),
      title: Text(run.toolId),
      subtitle: Text('${run.status} · ${_short(run.input)}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  String _short(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    return normalized.length <= 28
        ? normalized
        : '${normalized.substring(0, 28)}...';
  }
}

class _HistorySheet extends StatelessWidget {
  const _HistorySheet({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      maxChildSize: 0.95,
      minChildSize: 0.45,
      builder: (context, controller) {
        return ListView(
          controller: controller,
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        );
      },
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            isUser ? AppColors.primaryBlue.withOpacity(0.08) : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isUser ? '我' : 'AI',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                CopyIconButton(text: message.content),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            SelectableText(message.content),
            if (message.attachments.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _AttachmentList(attachments: message.attachments),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToolRunDetail extends StatelessWidget {
  const _ToolRunDetail({required this.run});

  final ToolRun run;

  @override
  Widget build(BuildContext context) {
    final result = run.output['result']?.toString();
    final artifacts = _artifacts(run.output['artifacts']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetaText(label: '工具', value: run.toolId),
        _MetaText(label: '状态', value: run.status),
        _MetaText(label: '输入', value: run.input),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Text(
                '输出',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            CopyIconButton(text: result ?? ''),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SelectableText(result == null || result.isEmpty ? '暂无输出' : result),
        if (artifacts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text('附件', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          _ArtifactList(artifacts: artifacts),
        ],
      ],
    );
  }

  List<Map<String, dynamic>> _artifacts(Object? value) {
    if (value is! List) {
      return const [];
    }
    return value
        .whereType<Map>()
        .map(
            (item) => item.map((key, value) => MapEntry(key.toString(), value)))
        .toList(growable: false);
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text('$label：$value'),
    );
  }
}

class _AttachmentList extends StatelessWidget {
  const _AttachmentList({required this.attachments});

  final List<ChatAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: attachments.map((attachment) {
        if (attachment.kind == 'IMAGE') {
          return ArtifactAttachmentCard(
            name: attachment.name,
            kind: attachment.kind,
            mimeType: attachment.mimeType,
            base64Data: attachment.base64Data,
            url: attachment.url,
            width: 180,
          );
        }
        return Chip(label: Text(attachment.name));
      }).toList(growable: false),
    );
  }
}

class _ArtifactList extends StatelessWidget {
  const _ArtifactList({required this.artifacts});

  final List<Map<String, dynamic>> artifacts;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: artifacts.map((artifact) {
        final kind = artifact['kind']?.toString() ?? 'FILE';
        final name = artifact['name']?.toString() ?? '输出附件';
        if (kind == 'IMAGE') {
          return ArtifactAttachmentCard(
            name: name,
            kind: kind,
            mimeType: artifact['mimeType']?.toString() ?? 'image/png',
            base64Data: artifact['base64Data']?.toString(),
            url: artifact['url']?.toString(),
          );
        }
        return Chip(
          avatar: const Icon(Icons.attach_file, size: 16),
          label: Text(name),
        );
      }).toList(growable: false),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Text(
            '暂无历史记录，完成一次对话或工具调用后会显示在这里。',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

class ModelsPage extends ConsumerWidget {
  const ModelsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final models = ref.watch(aiModelsProvider);
    final selectedModelId = ref.watch(selectedModelIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('模型选择')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemBuilder: (context, index) {
          final model = models[index];
          final isSelected = model.id == selectedModelId;

          return ListTile(
            tileColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: BorderSide(
                color: isSelected ? AppColors.primaryBlue : AppColors.border,
              ),
            ),
            leading: Icon(
              isSelected ? Icons.radio_button_checked : Icons.circle_outlined,
              color:
                  isSelected ? AppColors.primaryBlue : AppColors.textTertiary,
            ),
            title: Text(model.name),
            subtitle: Text(model.description),
            onTap: () {
              ref.read(selectedModelIdProvider.notifier).state = model.id;
              showAppSnackBar(context, '已切换模型：${model.name}');
            },
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: AppSpacing.md);
        },
        itemCount: models.length,
      ),
    );
  }
}

class MembershipPage extends StatelessWidget {
  const MembershipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('会员中心')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.featuredSurface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.workspace_premium,
                  color: AppColors.warning,
                  size: 36,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '边界 AI 会员',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '当前为 Demo 占位页，后续接入会员权益、积分额度和订单系统。',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: () => showAppSnackBar(context, '会员购买后续接入'),
                  child: const Text('查看权益'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GenericPlaceholderPage extends StatelessWidget {
  const GenericPlaceholderPage({
    required this.type,
    super.key,
  });

  final String type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('占位页面')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text('类型：$type\n后续会替换成正式页面或弹层。'),
          ),
        ),
      ),
    );
  }
}
