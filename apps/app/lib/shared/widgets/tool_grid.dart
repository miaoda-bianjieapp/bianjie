import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../models/tool.dart';
import 'app_state_panel.dart';

class ToolGrid extends StatelessWidget {
  const ToolGrid({
    required this.tools,
    required this.onToolTap,
    this.crossAxisCount = 4,
    this.mainAxisExtent = 126,
    super.key,
  });

  final List<Tool> tools;
  final ValueChanged<Tool> onToolTap;
  final int crossAxisCount;
  final double mainAxisExtent;

  @override
  Widget build(BuildContext context) {
    if (tools.isEmpty) {
      return const _EmptyTools();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tools.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        mainAxisExtent: mainAxisExtent,
      ),
      itemBuilder: (context, index) {
        final tool = tools[index];
        return ToolGridItem(tool: tool, onTap: () => onToolTap(tool));
      },
    );
  }
}

class ToolGridItem extends StatelessWidget {
  const ToolGridItem({
    required this.tool,
    required this.onTap,
    super.key,
  });

  final Tool tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconStyle = ToolIconStyle.forTool(tool);

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Stack(
          children: [
            if (tool.requiresVip)
              Positioned(
                top: 6,
                right: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    child: Text(
                      'VIP',
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 9,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox.square(
                    dimension: 44,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: iconStyle.backgroundColor,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        tool.icon,
                        color: iconStyle.color,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 34,
                    child: Center(
                      child: Text(
                        tool.name,
                        textScaler: TextScaler.noScaling,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

class ToolListTile extends StatelessWidget {
  const ToolListTile({
    required this.tool,
    required this.onTap,
    super.key,
  });

  final Tool tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconStyle = ToolIconStyle.forTool(tool);

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 44,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: iconStyle.backgroundColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    tool.icon,
                    color: iconStyle.color,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      tool.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (tool.requiresVip)
                const Padding(
                  padding: EdgeInsets.only(left: AppSpacing.sm),
                  child: Text(
                    'VIP',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ToolPillWrap extends StatelessWidget {
  const ToolPillWrap({
    required this.tools,
    required this.onToolTap,
    super.key,
  });

  final List<Tool> tools;
  final ValueChanged<Tool> onToolTap;

  @override
  Widget build(BuildContext context) {
    if (tools.isEmpty) {
      return const _EmptyTools();
    }

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: tools
          .map(
            (tool) => ToolPill(
              tool: tool,
              onTap: () => onToolTap(tool),
            ),
          )
          .toList(growable: false),
    );
  }
}

class ToolPill extends StatelessWidget {
  const ToolPill({
    required this.tool,
    required this.onTap,
    super.key,
  });

  final Tool tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconStyle = ToolIconStyle.forTool(tool);

    return Material(
      color: AppColors.chip,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 14, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ToolIconBadge(
                icon: tool.icon,
                style: iconStyle,
                size: 22,
                iconSize: 15,
                showDot: tool.tags.contains('新增'),
              ),
              const SizedBox(width: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(
                  tool.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (tool.requiresVip) ...[
                const SizedBox(width: AppSpacing.xs),
                const Text(
                  'VIP',
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ToolIconStyle {
  const ToolIconStyle({
    required this.color,
    required this.backgroundColor,
  });

  final Color color;
  final Color backgroundColor;

  static ToolIconStyle forTool(Tool tool) {
    final palette = <Color>[
      AppColors.accentBlue,
      AppColors.accentOrange,
      AppColors.accentCyan,
      AppColors.accentGreen,
      AppColors.accentPurple,
    ];
    final seed = tool.id.codeUnits.fold<int>(0, (value, unit) => value + unit);
    final color = palette[seed % palette.length];

    return ToolIconStyle(
      color: color,
      backgroundColor: color.withOpacity(0.12),
    );
  }
}

class _ToolIconBadge extends StatelessWidget {
  const _ToolIconBadge({
    required this.icon,
    required this.style,
    required this.size,
    required this.iconSize,
    this.showDot = false,
  });

  final IconData icon;
  final ToolIconStyle style;
  final double size;
  final double iconSize;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox.square(
          dimension: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: style.backgroundColor,
              borderRadius: BorderRadius.circular(size * 0.28),
            ),
            child: Icon(
              icon,
              color: style.color,
              size: iconSize,
            ),
          ),
        ),
        if (showDot)
          const Positioned(
            right: -2,
            top: -2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(dimension: 8),
            ),
          ),
      ],
    );
  }
}

class _EmptyTools extends StatelessWidget {
  const _EmptyTools();

  @override
  Widget build(BuildContext context) {
    return const AppStatePanel(
      icon: Icons.search_off,
      title: '暂无匹配工具',
      message: '换个关键词或切换分类试试。',
    );
  }
}
