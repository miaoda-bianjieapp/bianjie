import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/snackbar.dart';
import '../../../shared/models/chat_attachment.dart';
import '../../../shared/models/chat_message.dart';
import '../../../shared/providers/chat_providers.dart';
import '../../../shared/providers/mock_data_providers.dart';
import '../../../shared/providers/permission_providers.dart';
import '../../../shared/widgets/artifact_attachment_card.dart';
import '../../../shared/widgets/copy_icon_button.dart';
import '../../../shared/widgets/input_composer.dart';
import '../../../shared/widgets/model_badge.dart';
import '../../../shared/widgets/prompt_chip.dart';
import '../../../shared/widgets/section_header.dart';
import 'office_tab.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _controller = TextEditingController();
  String _channel = '对话';
  ChatAttachment? _selectedImage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prompts = ref.watch(homePromptsProvider);
    final selectedModel = ref.watch(selectedModelProvider);
    final chatState = ref.watch(chatControllerProvider);
    final hasMessages = chatState.messages.isNotEmpty;

    final channelContent = switch (_channel) {
      '办公' => const OfficeTab(),
      '助理' => const _AssistantPlaceholder(),
      _ => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasMessages) ...[
              _ChatHeader(
                title: chatState.session?.title ?? '当前对话',
                needsCompression: chatState.session?.needsCompression ?? false,
                onNewChat: () {
                  ref.read(chatControllerProvider.notifier).startNewSession();
                  showAppSnackBar(context, '已开启新的对话');
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _MessageList(messages: chatState.messages),
            ] else ...[
              _PromoBanner(
                title: '边界 AI 工具平台',
                subtitle: '对话、办公、股票和智能体任务从这里开始。',
                icon: Icons.auto_awesome,
                onTap: () => context.push('/membership'),
              ),
              const SizedBox(height: AppSpacing.md),
              _PromoBanner(
                title: '股票分析 Pro',
                subtitle: '财报解读、策略回测、市场概览一站承接。',
                icon: Icons.show_chart,
                onTap: () => context.go('/stock'),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: '推荐 Prompt',
                action: '历史',
                onAction: () => context.push('/history'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: prompts
                    .map(
                      (prompt) => PromptChip(
                        prompt: prompt,
                        onTap: () => context.push(prompt.target),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            InputComposer(
              controller: _controller,
              hintText: '发消息或选择文件进行 AI 提问',
              onSend: chatState.isSending ? () {} : _sendMessage,
              actions: [
                ComposerActionChip(
                  icon: Icons.tune,
                  label: '模型',
                  onTap: () => context.push('/models'),
                ),
                ComposerActionChip(
                  icon: Icons.task_alt,
                  label: '任务',
                  onTap: () => showAppSnackBar(context, '任务模式占位反馈'),
                ),
                ComposerActionChip(
                  icon: Icons.mic_none,
                  label: '语音',
                  onTap: () => showAppSnackBar(context, '语音输入后续接入'),
                ),
                ComposerActionChip(
                  icon: Icons.add_link,
                  label: '附件',
                  onTap: chatState.isSending ? () {} : _pickImageAttachment,
                ),
              ],
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _SelectedAttachment(
                attachment: _selectedImage!,
                onRemove: () => setState(() => _selectedImage = null),
              ),
            ],
            if (chatState.isSending) ...[
              const SizedBox(height: AppSpacing.sm),
              const LinearProgressIndicator(minHeight: 3),
            ],
            if (chatState.error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                chatState.error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: ModelBadge(
                label: selectedModel,
                onTap: () => context.push('/models'),
              ),
            ),
          ],
        ),
    };

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xxl,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        children: [
          _TopBar(
            channel: _channel,
            onChannelChanged: (value) => setState(() => _channel = value),
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: KeyedSubtree(
              key: ValueKey(_channel),
              child: channelContent,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    final attachments =
        _selectedImage == null ? const <ChatAttachment>[] : [_selectedImage!];
    if (text.isEmpty && attachments.isEmpty) {
      showAppSnackBar(context, '请输入问题或选择图片附件');
      return;
    }
    final model = ref.read(selectedAiModelProvider);
    _controller.clear();
    setState(() => _selectedImage = null);
    ref.read(chatControllerProvider.notifier).send(
          content: text.isEmpty ? '请分析这张图片' : text,
          modelId: model.id,
          modelName: model.name,
          attachments: attachments,
        );
  }

  Future<void> _pickImageAttachment() async {
    try {
      final attachment =
          await ref.read(imageAttachmentServiceProvider).pickImage();
      if (!mounted || attachment == null) {
        return;
      }
      setState(() => _selectedImage = attachment);
      showAppSnackBar(context, '图片已处理，可发送给 AI');
    } catch (error) {
      if (mounted) {
        showAppSnackBar(context, error.toString());
      }
    }
  }
}

class _SelectedAttachment extends StatelessWidget {
  const _SelectedAttachment({
    required this.attachment,
    required this.onRemove,
  });

  final ChatAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const Icon(Icons.image_outlined, color: AppColors.primaryBlue),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '${attachment.name} · ${(attachment.size / 1024).ceil()}KB',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close),
              tooltip: '移除附件',
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.title,
    required this.needsCompression,
    required this.onNewChat,
  });

  final String title;
  final bool needsCompression;
  final VoidCallback onNewChat;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                needsCompression ? '上下文已达到整理阈值' : '当前对话会保留完整消息历史',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: onNewChat,
          icon: const Icon(Icons.add),
          label: const Text('新对话'),
        ),
      ],
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.messages});

  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: messages
          .map(
            (message) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _MessageBubble(message: message),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isUser ? AppColors.primaryBlue : AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: isUser ? null : Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    color: isUser ? Colors.white : AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
                if (message.attachments.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ...message.attachments.map(
                    (attachment) => Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: _AttachmentPreview(
                        attachment: attachment,
                        compact: isUser,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isUser ? message.modelName : 'AI 回复',
                        style: TextStyle(
                          color:
                              isUser ? Colors.white70 : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    CopyIconButton(
                      text: message.content,
                      color: isUser ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({
    required this.attachment,
    required this.compact,
  });

  final ChatAttachment attachment;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (attachment.kind == 'IMAGE') {
      return ArtifactAttachmentCard(
        name: attachment.name,
        kind: attachment.kind,
        mimeType: attachment.mimeType,
        base64Data: attachment.base64Data,
        url: attachment.url,
        width: compact ? 180 : 220,
      );
    }

    final foreground = compact ? Colors.white70 : AppColors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          attachment.kind == 'AUDIO'
              ? Icons.graphic_eq
              : attachment.kind == 'VIDEO'
                  ? Icons.movie_outlined
                  : attachment.kind == 'IMAGE'
                      ? Icons.image_outlined
                      : Icons.attach_file,
          color: foreground,
          size: 16,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            attachment.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.channel,
    required this.onChannelChanged,
  });

  final String channel;
  final ValueChanged<String> onChannelChanged;

  @override
  Widget build(BuildContext context) {
    const channels = ['对话', '办公', '助理'];

    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: channels
                  .map(
                    (item) => _ChannelTab(
                      label: item,
                      selected: item == channel,
                      onTap: () => onChannelChanged(item),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          IconButton(
            tooltip: '搜索',
            visualDensity: VisualDensity.compact,
            onPressed: () => showAppSnackBar(context, '搜索即将上线'),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: '历史记录',
            visualDensity: VisualDensity.compact,
            onPressed: () => context.push('/history'),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
    );
  }
}

class _ChannelTab extends StatelessWidget {
  const _ChannelTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color:
                      selected ? AppColors.textPrimary : AppColors.textTertiary,
                  fontSize: 17,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: selected ? 26 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistantPlaceholder extends StatelessWidget {
  const _AssistantPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 72),
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const SizedBox(
              width: 72,
              height: 72,
              child: Icon(
                Icons.smart_toy_outlined,
                color: AppColors.primaryBlue,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('智能助理', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            '敬请期待',
            style: TextStyle(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 34),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
