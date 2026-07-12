import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/snackbar.dart';
import '../../../shared/models/chat_attachment.dart';
import '../../../shared/models/tool.dart';
import '../../../shared/models/tool_run.dart';
import '../../../shared/providers/mock_data_providers.dart';
import '../../../shared/providers/permission_providers.dart';
import '../../../shared/providers/tool_execution_providers.dart';
import '../../../shared/widgets/app_state_panel.dart';
import '../../../shared/widgets/artifact_attachment_card.dart';
import '../../../shared/widgets/copy_icon_button.dart';
import '../../../shared/widgets/input_composer.dart';

class ToolRunnerPage extends ConsumerStatefulWidget {
  const ToolRunnerPage({
    required this.toolId,
    super.key,
  });

  final String toolId;

  @override
  ConsumerState<ToolRunnerPage> createState() => _ToolRunnerPageState();
}

class _ToolRunnerPageState extends ConsumerState<ToolRunnerPage> {
  late final TextEditingController _controller;
  final Map<String, TextEditingController> _fieldControllers = {};
  final Map<String, Object?> _fieldValues = {};
  final List<ChatAttachment> _attachments = [];
  ToolRun? _run;
  bool _isRunning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final controller in _fieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tools = ref.watch(toolsProvider);
    final tool = tools.firstWhere(
      (item) => item.id == widget.toolId,
      orElse: () => Tool(
        id: widget.toolId,
        name: '工具执行',
        description: '当前工具还没有配置本地数据，先展示通用执行模板。',
        categoryId: 'placeholder',
        tab: 'tools',
        icon: Icons.construction_outlined,
        tags: const ['占位'],
        route: '/tool/${widget.toolId}',
        enabled: true,
        sortOrder: 999,
        requiresLogin: false,
        requiresVip: false,
        executionType: ToolExecutionType.placeholder,
      ),
    );
    final fields = _ToolField.fromTool(tool);
    final primaryInput = _PrimaryInputConfig.fromTool(tool);
    _syncFieldState(fields);

    return Scaffold(
      appBar: AppBar(title: Text(tool.name)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _ToolSummary(tool: tool),
          const SizedBox(height: AppSpacing.lg),
          if (tool.requiresVip || tool.requiresLogin) ...[
            AppStatePanel(
              icon: tool.requiresVip
                  ? Icons.workspace_premium_outlined
                  : Icons.login,
              title: tool.requiresVip ? '会员限制占位' : '登录后使用',
              message: tool.requiresVip
                  ? '当前工具标记为 VIP 能力，Demo 阶段只展示限制状态，不触发真实扣费。'
                  : '当前工具需要登录，Demo 阶段默认展示未登录占位边界。',
              actionLabel: tool.requiresVip ? '查看会员' : '登录占位',
              tone:
                  tool.requiresVip ? AppStateTone.locked : AppStateTone.warning,
              onAction: () => showAppSnackBar(
                context,
                tool.requiresVip ? '会员系统后续接入' : '登录系统后续接入',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (primaryInput != null) ...[
            _PrimaryInputPanel(
              config: primaryInput,
              controller: _controller,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (fields.isNotEmpty || _hasExecutionConfig(tool)) ...[
            _ToolConfigPanel(
              tool: tool,
              fields: fields,
              values: _fieldValues,
              controllers: _fieldControllers,
              onChanged: (name, value) {
                setState(() => _fieldValues[name] = value);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (_supportsAttachments(tool)) ...[
            _ToolAttachmentPanel(
              tool: tool,
              attachments: _attachments,
              isRunning: _isRunning,
              onAdd: () => _pickAttachments(tool),
              onRemove: (attachment) {
                setState(() => _attachments.remove(attachment));
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (primaryInput == null)
            InputComposer(
              controller: _controller,
              hintText: '输入需求或粘贴素材，点击发送后会调用工具生成结果。',
              onSend: _isRunning ? () {} : () => _runTool(tool),
              actions: [
                ComposerActionChip(
                  icon: Icons.tune,
                  label: '参数',
                  onTap: () => showAppSnackBar(
                    context,
                    fields.isEmpty ? '当前工具暂无额外参数' : '参数会随工具运行一起提交',
                  ),
                ),
                ComposerActionChip(
                  icon: Icons.workspace_premium_outlined,
                  label: tool.requiresVip ? 'VIP 工具' : '额度',
                  onTap: () => showAppSnackBar(context, '会员和额度系统后续接入'),
                ),
              ],
            )
          else
            _StructuredToolActions(
              isRunning: _isRunning,
              onReset: () => _resetForm(fields),
              onGenerate: () => _runTool(tool),
            ),
          const SizedBox(height: AppSpacing.lg),
          _ResultBox(
            isRunning: _isRunning,
            error: _error,
            run: _run,
            tool: tool,
          ),
        ],
      ),
    );
  }

  Future<void> _runTool(Tool tool) async {
    final fields = _ToolField.fromTool(tool);
    final primaryInput = _PrimaryInputConfig.fromTool(tool);
    final input = _controller.text.trim();
    if (input.isEmpty && _isInputRequired(tool, primaryInput)) {
      showAppSnackBar(context, '请填写${primaryInput?.label ?? '需求或素材'}');
      return;
    }
    if (primaryInput?.maxLength != null &&
        input.length > primaryInput!.maxLength!) {
      showAppSnackBar(
          context, '${primaryInput.label}不能超过${primaryInput.maxLength}字');
      return;
    }
    final validationError = _validateFields(fields);
    if (validationError != null) {
      showAppSnackBar(context, validationError);
      return;
    }
    final attachmentError = _validateAttachments(tool);
    if (attachmentError != null) {
      showAppSnackBar(context, attachmentError);
      return;
    }

    setState(() {
      _isRunning = true;
      _error = null;
    });

    try {
      final run = await ref.read(toolExecutionRepositoryProvider).createToolRun(
            tool.id,
            input: input,
            parameters: _collectParameters(tool, fields),
            attachments: List.unmodifiable(_attachments),
          );
      ref.invalidate(toolRunsHistoryProvider);
      if (!mounted) {
        return;
      }
      setState(() => _run = run);
      showAppSnackBar(context, run.status == 'QUEUED' ? '任务已创建' : '工具运行记录已创建');
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.toString());
      showAppSnackBar(context, '工具执行失败，请稍后重试');
    } finally {
      if (mounted) {
        setState(() => _isRunning = false);
      }
    }
  }

  void _resetForm(List<_ToolField> fields) {
    _controller.clear();
    for (final field in fields.where((field) => field.isTextInput)) {
      _fieldControllers[field.name]?.text =
          field.initialValue?.toString() ?? '';
    }
    setState(() {
      _run = null;
      _error = null;
      _attachments.clear();
      for (final field in fields) {
        _fieldValues[field.name] = field.defaultValue;
      }
    });
  }

  void _syncFieldState(List<_ToolField> fields) {
    final names = fields.map((field) => field.name).toSet();
    final staleNames = _fieldControllers.keys
        .where((name) => !names.contains(name))
        .toList(growable: false);
    for (final name in staleNames) {
      _fieldControllers.remove(name)?.dispose();
      _fieldValues.remove(name);
    }

    for (final field in fields) {
      if (field.isTextInput) {
        _fieldControllers.putIfAbsent(
          field.name,
          () => TextEditingController(
            text: field.initialValue?.toString() ?? '',
          ),
        );
      }
      if (!_fieldValues.containsKey(field.name)) {
        _fieldValues[field.name] = field.defaultValue;
      }
    }
  }

  String? _validateFields(List<_ToolField> fields) {
    for (final field in fields) {
      final value = _readFieldValue(field);
      if (field.required && _isBlank(value)) {
        return '请填写${field.label}';
      }
      if (field.type == _ToolFieldType.number &&
          !_isBlank(_fieldControllers[field.name]?.text) &&
          value == null) {
        return '${field.label}请输入数字';
      }
      if (field.type == _ToolFieldType.number && !_isBlank(value)) {
        final number = value as num;
        if (field.min != null && number < field.min!) {
          return '${field.label}不能小于${field.min}';
        }
        if (field.max != null && number > field.max!) {
          return '${field.label}不能大于${field.max}';
        }
      }
      if (field.maxLength != null &&
          value is String &&
          value.length > field.maxLength!) {
        return '${field.label}不能超过${field.maxLength}字';
      }
    }
    return null;
  }

  Map<String, dynamic> _collectParameters(Tool tool, List<_ToolField> fields) {
    final parameters = <String, dynamic>{
      'executionType': tool.executionType.name,
      'source': 'flutter-tool-runner',
      'toolConfigVersion': tool.config['version'] ?? 'demo',
    };
    final model = ref.read(selectedAiModelProvider);
    parameters['modelId'] = model.id;
    parameters['modelName'] = model.name;
    for (final field in fields) {
      final value = _readFieldValue(field);
      if (!_isBlank(value)) {
        parameters[field.name] = value;
      }
    }
    return parameters;
  }

  Object? _readFieldValue(_ToolField field) {
    if (field.type == _ToolFieldType.text ||
        field.type == _ToolFieldType.textarea) {
      return _fieldControllers[field.name]?.text.trim();
    }
    if (field.type == _ToolFieldType.number) {
      final text = _fieldControllers[field.name]?.text.trim() ?? '';
      return text.isEmpty ? null : num.tryParse(text);
    }
    return _fieldValues[field.name];
  }

  bool _isBlank(Object? value) {
    if (value == null) {
      return true;
    }
    if (value is String) {
      return value.trim().isEmpty;
    }
    if (value is Iterable<Object?>) {
      return value.isEmpty;
    }
    return false;
  }

  bool _isInputRequired(Tool tool, _PrimaryInputConfig? primaryInput) {
    final configured = tool.config['inputRequired'];
    if (configured is bool) {
      return configured;
    }
    if (primaryInput != null) {
      return primaryInput.required;
    }
    final modes = _inputModes(tool);
    return modes.contains('text') &&
        !modes.contains('file') &&
        !modes.contains('image');
  }

  bool _hasExecutionConfig(Tool tool) {
    return (tool.config['inputModes'] as List<dynamic>?)?.isNotEmpty == true ||
        (tool.config['acceptedFileTypes'] as List<dynamic>?)?.isNotEmpty ==
            true ||
        (tool.config['outputFormats'] as List<dynamic>?)?.isNotEmpty == true;
  }

  Set<String> _inputModes(Tool tool) {
    final inputModes = tool.config['inputModes'] as List<dynamic>? ?? const [];
    return inputModes.map((item) => item.toString().toLowerCase()).toSet();
  }

  bool _supportsAttachments(Tool tool) {
    final modes = _inputModes(tool);
    return modes.contains('image') || modes.contains('file');
  }

  int _intConfig(Tool tool, String name, int fallback) {
    final value = tool.config[name];
    return value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
  }

  String? _validateAttachments(Tool tool) {
    final minFiles = _intConfig(tool, 'minFiles', 0);
    final maxFiles = _intConfig(tool, 'maxFiles', 1);
    if (_attachments.length < minFiles) {
      return '请至少添加$minFiles个文件';
    }
    if (_attachments.length > maxFiles) {
      return '最多只能添加$maxFiles个文件';
    }
    return null;
  }

  Future<void> _pickAttachments(Tool tool) async {
    if (_inputModes(tool).contains('image') &&
        !_inputModes(tool).contains('file')) {
      await _pickImageAttachment(tool);
      return;
    }
    await _pickFileAttachments(tool);
  }

  Future<void> _pickImageAttachment(Tool tool) async {
    try {
      final maxFiles = _intConfig(tool, 'maxFiles', 1);
      if (_attachments.length >= maxFiles) {
        showAppSnackBar(context, '最多只能添加$maxFiles张图片');
        return;
      }
      final attachment =
          await ref.read(imageAttachmentServiceProvider).pickImage();
      if (!mounted || attachment == null) {
        return;
      }
      setState(() => _attachments.add(attachment));
      showAppSnackBar(context, '参考图已添加');
    } catch (error) {
      if (mounted) {
        showAppSnackBar(context, error.toString());
      }
    }
  }

  Future<void> _pickFileAttachments(Tool tool) async {
    try {
      final maxFiles = _intConfig(tool, 'maxFiles', 1);
      final remaining = maxFiles - _attachments.length;
      if (remaining <= 0) {
        showAppSnackBar(context, '最多只能添加$maxFiles个文件');
        return;
      }
      final extensions =
          (tool.config['acceptedFileTypes'] as List<dynamic>? ?? const [])
              .map((item) => item.toString().toLowerCase())
              .toList(growable: false);
      final attachments =
          await ref.read(fileAttachmentServiceProvider).pickFiles(
                acceptedExtensions: extensions,
                maxFiles: remaining,
                maxFileSizeMb: _intConfig(tool, 'maxFileSizeMb', 10),
              );
      if (!mounted || attachments.isEmpty) {
        return;
      }
      setState(() => _attachments.addAll(attachments));
      showAppSnackBar(context, '已添加${attachments.length}个文件');
    } catch (error) {
      if (mounted) {
        showAppSnackBar(context, error.toString());
      }
    }
  }
}

class _ToolAttachmentPanel extends StatelessWidget {
  const _ToolAttachmentPanel({
    required this.tool,
    required this.attachments,
    required this.isRunning,
    required this.onAdd,
    required this.onRemove,
  });

  final Tool tool;
  final List<ChatAttachment> attachments;
  final bool isRunning;
  final VoidCallback onAdd;
  final ValueChanged<ChatAttachment> onRemove;

  @override
  Widget build(BuildContext context) {
    final types =
        (tool.config['acceptedFileTypes'] as List<dynamic>? ?? const [])
            .map((item) => item.toString().toUpperCase())
            .join(' / ');
    final maxFiles = tool.config['maxFiles'] as num? ?? 1;
    final maxSize = tool.config['maxFileSizeMb'] as num?;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_file, color: AppColors.accentOrange),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '输入附件',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: isRunning ? null : onAdd,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(attachments.isEmpty ? '添加' : '继续添加'),
                ),
              ],
            ),
            if (types.isNotEmpty || maxSize != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                [
                  if (types.isNotEmpty) types,
                  '最多${maxFiles.toInt()}个',
                  if (maxSize != null) '单个不超过${maxSize.toInt()}MB',
                ].join(' · '),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
            if (attachments.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              ...attachments.map(
                (attachment) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _SelectedToolAttachment(
                    attachment: attachment,
                    onRemove: () => onRemove(attachment),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SelectedToolAttachment extends StatelessWidget {
  const _SelectedToolAttachment({
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
            Icon(
              attachment.kind == 'IMAGE'
                  ? Icons.image_outlined
                  : Icons.description_outlined,
              color: AppColors.primaryBlue,
            ),
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

class _PrimaryInputConfig {
  const _PrimaryInputConfig({
    required this.label,
    required this.placeholder,
    required this.required,
    required this.minLines,
    required this.maxLines,
    required this.maxLength,
    required this.example,
  });

  factory _PrimaryInputConfig.fromJson(Map<String, dynamic> json) {
    return _PrimaryInputConfig(
      label: json['label'] as String? ?? '主题',
      placeholder: json['placeholder'] as String?,
      required: json['required'] as bool? ?? true,
      minLines: json['minLines'] as int? ?? 5,
      maxLines: json['maxLines'] as int? ?? 8,
      maxLength: json['maxLength'] as int?,
      example: json['example'] as String?,
    );
  }

  static _PrimaryInputConfig? fromTool(Tool tool) {
    final value = tool.config['primaryInput'];
    if (value is! Map) {
      return null;
    }
    return _PrimaryInputConfig.fromJson(
      value.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  final String label;
  final String? placeholder;
  final bool required;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final String? example;
}

class _PrimaryInputPanel extends StatelessWidget {
  const _PrimaryInputPanel({
    required this.config,
    required this.controller,
  });

  final _PrimaryInputConfig config;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              config.required ? '${config.label} *' : config.label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: controller,
              minLines: config.minLines,
              maxLines: config.maxLines,
              maxLength: config.maxLength,
              decoration: InputDecoration(
                hintText: config.placeholder,
                filled: true,
                fillColor: AppColors.surfaceSoft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (config.example != null && config.example!.isNotEmpty)
              TextButton.icon(
                onPressed: () => controller.text = config.example!,
                icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                label: const Text('插入示例'),
              ),
          ],
        ),
      ),
    );
  }
}

class _StructuredToolActions extends StatelessWidget {
  const _StructuredToolActions({
    required this.isRunning,
    required this.onReset,
    required this.onGenerate,
  });

  final bool isRunning;
  final VoidCallback onReset;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isRunning ? null : onReset,
            icon: const Icon(Icons.delete_outline),
            label: const Text('重置内容'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: FilledButton.icon(
            onPressed: isRunning ? null : onGenerate,
            icon: isRunning
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(isRunning ? '生成中' : '立即生成'),
          ),
        ),
      ],
    );
  }
}

enum _ToolFieldType {
  text,
  textarea,
  number,
  select,
  chips,
  segmented,
  slider,
  boolean,
}

class _ToolField {
  const _ToolField({
    required this.name,
    required this.label,
    required this.type,
    required this.required,
    required this.options,
    required this.placeholder,
    required this.minLines,
    required this.maxLines,
    required this.maxLength,
    required this.initialValue,
    required this.divisions,
    this.min,
    this.max,
  });

  factory _ToolField.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String? ?? 'text';
    final type = _ToolFieldType.values.firstWhere(
      (item) => item.name == typeName,
      orElse: () => _ToolFieldType.text,
    );
    return _ToolField(
      name: json['name'] as String? ?? '',
      label: json['label'] as String? ?? json['name'] as String? ?? '参数',
      type: type,
      required: json['required'] as bool? ?? false,
      options: (json['options'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      placeholder: json['placeholder'] as String?,
      minLines: json['minLines'] as int?,
      maxLines: json['maxLines'] as int?,
      maxLength: json['maxLength'] as int?,
      initialValue: json['defaultValue'],
      divisions: json['divisions'] as int?,
      min: json['min'] as num?,
      max: json['max'] as num?,
    );
  }

  static List<_ToolField> fromTool(Tool tool) {
    final fields = tool.config['fields'] as List<dynamic>? ?? const [];
    return fields
        .whereType<Map<String, dynamic>>()
        .map(_ToolField.fromJson)
        .where((field) => field.name.isNotEmpty)
        .toList(growable: false);
  }

  final String name;
  final String label;
  final _ToolFieldType type;
  final bool required;
  final List<String> options;
  final String? placeholder;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final Object? initialValue;
  final int? divisions;
  final num? min;
  final num? max;

  bool get isTextInput =>
      type == _ToolFieldType.text ||
      type == _ToolFieldType.textarea ||
      type == _ToolFieldType.number;

  Object? get defaultValue {
    if (initialValue != null) {
      return initialValue;
    }
    if (type == _ToolFieldType.boolean) {
      return false;
    }
    if ((type == _ToolFieldType.select ||
            type == _ToolFieldType.chips ||
            type == _ToolFieldType.segmented) &&
        options.isNotEmpty) {
      return options.first;
    }
    if (type == _ToolFieldType.slider) {
      return min ?? 0;
    }
    return null;
  }
}

class _ToolConfigPanel extends StatelessWidget {
  const _ToolConfigPanel({
    required this.tool,
    required this.fields,
    required this.values,
    required this.controllers,
    required this.onChanged,
  });

  final Tool tool;
  final List<_ToolField> fields;
  final Map<String, Object?> values;
  final Map<String, TextEditingController> controllers;
  final void Function(String name, Object? value) onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, color: AppColors.primaryBlue),
                const SizedBox(width: AppSpacing.sm),
                Text('运行参数', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _ConfigChips(tool: tool),
            if (fields.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              ...fields.map(
                (field) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _ToolFieldInput(
                    field: field,
                    value: values[field.name],
                    controller: controllers[field.name],
                    onChanged: (value) => onChanged(field.name, value),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConfigChips extends StatelessWidget {
  const _ConfigChips({required this.tool});

  final Tool tool;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      ..._chips('输入', tool.config['inputModes']),
      ..._chips('文件', tool.config['acceptedFileTypes']),
      ..._chips('输出', tool.config['outputFormats']),
    ];
    if (chips.isEmpty) {
      return const Text(
        '当前工具使用默认输入参数。',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: chips,
    );
  }

  List<Widget> _chips(String label, Object? value) {
    final items = value is List<dynamic> ? value : const [];
    return items
        .map(
          (item) => Chip(
            label: Text('$label ${item.toString()}'),
            backgroundColor: AppColors.primaryBlue.withOpacity(0.08),
            side: BorderSide.none,
          ),
        )
        .toList(growable: false);
  }
}

class _ToolFieldInput extends StatelessWidget {
  const _ToolFieldInput({
    required this.field,
    required this.value,
    required this.controller,
    required this.onChanged,
  });

  final _ToolField field;
  final Object? value;
  final TextEditingController? controller;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case _ToolFieldType.select:
        return DropdownButtonFormField<String>(
          value: value as String?,
          items: field.options
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList(growable: false),
          decoration: _decoration(),
          onChanged: (value) => onChanged(value),
        );
      case _ToolFieldType.chips:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_label, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: field.options
                  .map(
                    (option) => ChoiceChip(
                      label: Text(option),
                      selected: value == option,
                      showCheckmark: false,
                      onSelected: (_) => onChanged(option),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        );
      case _ToolFieldType.segmented:
        final selected = value?.toString();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_label, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<String>(
                segments: field.options
                    .map(
                      (option) => ButtonSegment<String>(
                        value: option,
                        label: Text(option),
                      ),
                    )
                    .toList(growable: false),
                selected: {
                  if (selected != null && field.options.contains(selected))
                    selected,
                },
                emptySelectionAllowed: !field.required,
                showSelectedIcon: false,
                onSelectionChanged: (selection) {
                  onChanged(selection.isEmpty ? null : selection.first);
                },
              ),
            ),
          ],
        );
      case _ToolFieldType.slider:
        final min = (field.min ?? 0).toDouble();
        final max = (field.max ?? 100).toDouble();
        final current =
            ((value as num?)?.toDouble() ?? min).clamp(min, max).toDouble();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  _formatNumber(current),
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Slider(
              value: current,
              min: min,
              max: max <= min ? min + 1 : max,
              divisions: field.divisions,
              label: _formatNumber(current),
              onChanged: onChanged,
            ),
          ],
        );
      case _ToolFieldType.boolean:
        return SwitchListTile(
          value: value == true,
          title: Text(_label),
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.primaryBlue,
          onChanged: onChanged,
        );
      case _ToolFieldType.number:
        return TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: _decoration(
            helperText: _numberHelperText,
          ),
        );
      case _ToolFieldType.textarea:
        return TextField(
          controller: controller,
          minLines: field.minLines ?? 3,
          maxLines: field.maxLines ?? 6,
          maxLength: field.maxLength,
          decoration: _decoration(),
        );
      case _ToolFieldType.text:
        return TextField(
          controller: controller,
          decoration: _decoration(),
        );
    }
  }

  String get _label => field.required ? '${field.label} *' : field.label;

  String? get _numberHelperText {
    if (field.min == null && field.max == null) {
      return null;
    }
    final minText = field.min == null ? '' : '最小 ${field.min}';
    final maxText = field.max == null ? '' : '最大 ${field.max}';
    return [minText, maxText].where((item) => item.isNotEmpty).join('，');
  }

  String _formatNumber(num value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  InputDecoration _decoration({String? helperText}) {
    return InputDecoration(
      labelText: _label,
      hintText: field.placeholder,
      helperText: helperText,
      border: const OutlineInputBorder(),
      isDense: true,
    );
  }
}

class _ToolSummary extends StatelessWidget {
  const _ToolSummary({required this.tool});

  final Tool tool;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(tool.icon, color: AppColors.primaryBlue, size: 32),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tool.name,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(tool.description),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: tool.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            backgroundColor:
                                AppColors.primaryBlue.withOpacity(0.08),
                            side: BorderSide.none,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultBox extends StatelessWidget {
  const _ResultBox({
    required this.isRunning,
    required this.error,
    required this.run,
    required this.tool,
  });

  final bool isRunning;
  final String? error;
  final ToolRun? run;
  final Tool tool;

  @override
  Widget build(BuildContext context) {
    final result = run?.output['result']?.toString();
    final artifacts = _artifacts(run?.output['artifacts']);
    final outputText = _formatMap(run?.output);
    final parameterText = _formatMap(run?.parameters);
    final copyText =
        result != null && result.isNotEmpty ? result : outputText ?? '';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('执行结果', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            if (isRunning) ...[
              const LinearProgressIndicator(minHeight: 3),
              const SizedBox(height: AppSpacing.md),
              const Text('正在创建工具运行记录...'),
            ] else if (error != null) ...[
              Text(
                error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ] else if (run != null) ...[
              _MetaRow(label: '运行 ID', value: run!.id),
              _MetaRow(label: '工具', value: tool.name),
              _StatusRow(status: run!.status),
              const SizedBox(height: AppSpacing.sm),
              if (parameterText != null) ...[
                const Text(
                  '提交参数',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(parameterText),
                const SizedBox(height: AppSpacing.md),
              ],
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '执行输出',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  CopyIconButton(text: copyText),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              if (result != null && result.isNotEmpty)
                SelectableText(
                  result,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    height: 1.45,
                  ),
                )
              else
                Text(outputText ?? '暂无输出'),
              if (artifacts.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                const Text(
                  '输出附件',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.sm),
                _OutputArtifacts(artifacts: artifacts),
              ],
            ] else
              const Text('点击发送后，这里会展示工具运行状态和生成结果。'),
          ],
        ),
      ),
    );
  }

  String? _formatMap(Map<String, dynamic>? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return value.entries
        .where((entry) => entry.key != 'result' && entry.key != 'artifacts')
        .map((entry) => '${entry.key}: ${_formatValue(entry.value)}')
        .join('\n');
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

  String _formatValue(Object? value) {
    if (value is List) {
      return value.map(_formatValue).join('、');
    }
    if (value is Map) {
      return value.entries
          .map((entry) => '${entry.key}=${_formatValue(entry.value)}')
          .join('，');
    }
    return value?.toString() ?? '-';
  }
}

class _OutputArtifacts extends StatelessWidget {
  const _OutputArtifacts({required this.artifacts});

  final List<Map<String, dynamic>> artifacts;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: artifacts.map(_artifact).toList(growable: false),
    );
  }

  Widget _artifact(Map<String, dynamic> artifact) {
    final kind = artifact['kind']?.toString() ?? 'FILE';
    final name = artifact['name']?.toString() ?? '模型输出附件';
    if (kind == 'IMAGE') {
      return ArtifactAttachmentCard(
        name: name,
        kind: kind,
        mimeType: artifact['mimeType']?.toString() ?? 'image/png',
        base64Data: artifact['base64Data']?.toString(),
        url: artifact['url']?.toString(),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_iconFor(kind), size: 18, color: AppColors.primaryBlue),
            const SizedBox(width: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String kind) {
    return switch (kind) {
      'AUDIO' => Icons.graphic_eq,
      'VIDEO' => Icons.movie_outlined,
      'IMAGE' => Icons.image_outlined,
      _ => Icons.attach_file,
    };
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'QUEUED' => AppColors.warning,
      'FAILED' => Colors.redAccent,
      _ => AppColors.success,
    };
    final label = switch (status) {
      'QUEUED' => '任务排队中',
      'FAILED' => '执行失败',
      _ => '已完成',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          const SizedBox(
            width: 72,
            child: Text(
              '状态',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Chip(
            label: Text('$label ($status)'),
            backgroundColor: color.withOpacity(0.12),
            side: BorderSide.none,
            labelStyle: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
