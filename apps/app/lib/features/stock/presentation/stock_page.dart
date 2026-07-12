import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/snackbar.dart';
import '../../../shared/providers/mock_data_providers.dart';
import '../../../shared/widgets/input_composer.dart';
import '../../../shared/widgets/model_badge.dart';
import '../../../shared/widgets/section_header.dart';

class StockPage extends ConsumerStatefulWidget {
  const StockPage({super.key});

  @override
  ConsumerState<StockPage> createState() => _StockPageState();
}

class _StockPageState extends ConsumerState<StockPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(stockStatsProvider);
    final capabilities = ref.watch(stockCapabilitiesProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xxl,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => showAppSnackBar(context, '菜单占位'),
                icon: const Icon(Icons.menu),
              ),
              const Expanded(
                child: ModelBadge(
                  label: '股票 1.6 Pro Flash',
                  onTap: _noop,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/membership'),
                child: const Text('升级'),
              ),
              IconButton(
                onPressed: () => showAppSnackBar(context, '通知占位'),
                icon: const Icon(Icons.notifications_none),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: stats
                .map(
                  (stat) => Expanded(
                    child: _StatTile(
                      value: stat.value,
                      unit: stat.unit,
                      label: stat.label,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          InputComposer(
            controller: _controller,
            hintText: '分析某股票最新财报与估值，支持引用专家、调用技能与指令',
            onSend: () => showAppSnackBar(context, '股票分析任务生成中'),
            actions: [
              ComposerActionChip(
                icon: Icons.person_add_alt,
                label: '创建助手',
                onTap: () => showAppSnackBar(context, '创建助手占位'),
              ),
              ComposerActionChip(
                icon: Icons.extension_outlined,
                label: '技能',
                onTap: () => showAppSnackBar(context, '技能选择占位'),
              ),
              ComposerActionChip(
                icon: Icons.verified_user_outlined,
                label: '专家',
                onTap: () => showAppSnackBar(context, '专家库占位'),
              ),
              ComposerActionChip(
                icon: Icons.attach_file,
                label: '附件',
                onTap: () => showAppSnackBar(context, '附件占位'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: '快捷能力'),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: capabilities
                .map(
                  (capability) => ActionChip(
                    avatar: Icon(capability.icon, size: 18),
                    label: Text(capability.title),
                    onPressed: () {
                      if (capability.opensPage) {
                        context.push('/stock/${capability.id}');
                      } else {
                        _controller.text = capability.prompt;
                        showAppSnackBar(context, '已填入分析模板');
                      }
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

void _noop() {}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.unit,
    required this.label,
  });

  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text(
              '$value$unit',
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
