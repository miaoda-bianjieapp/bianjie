import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/snackbar.dart';

class OfficeTab extends StatelessWidget {
  const OfficeTab({super.key});

  static final _tools = [
    _OfficeTool(
        '写一篇文章', '快速生成完整文章', Icons.article_outlined, AppColors.accentOrange),
    _OfficeTool('按风格写文章', '自定义表达风格', Icons.auto_stories_outlined,
        AppColors.accentPurple),
    _OfficeTool(
        '文章改写', '调整结构与表达', Icons.find_replace_rounded, AppColors.accentBlue),
    _OfficeTool('文案润色', '提升文字质感', Icons.draw_outlined, AppColors.warning),
    _OfficeTool('万字长文', '根据主题生成长文', Icons.edit_document, AppColors.primaryBlue),
    _OfficeTool('内容伪原创', '重组内容与措辞', Icons.code_rounded, AppColors.accentCyan),
    _OfficeTool('文章扩写', '补充细节和论述', Icons.expand_rounded, AppColors.danger),
    _OfficeTool(
        '续写文章', '延续上下文写作', Icons.post_add_rounded, AppColors.accentGreen),
    _OfficeTool('按大纲写文章', '根据大纲完整成文', Icons.content_paste_go_outlined,
        AppColors.warning),
    _OfficeTool(
        '句子重写', '重新组织句子表达', Icons.sync_alt_rounded, AppColors.accentPurple),
    _OfficeTool(
        '写故事小说', '生成故事与小说', Icons.menu_book_outlined, AppColors.primaryBlue),
    _OfficeTool(
        '仿写', '参照范文重写内容', Icons.library_books_outlined, AppColors.accentOrange),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _OfficeFeature(
                title: '智能写作',
                subtitle: '提高写作效率',
                icon: Icons.edit_note_rounded,
                color: const Color(0xFFFF776B),
                onTap: () => _showPlaceholder(context, '智能写作'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _OfficeFeature(
                title: 'PPT 生成',
                subtitle: '一键生成演示文稿',
                icon: Icons.slideshow_rounded,
                color: const Color(0xFF5279E8),
                onTap: () => _showPlaceholder(context, 'PPT 生成'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          '常用办公',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _tools.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            mainAxisExtent: 94,
          ),
          itemBuilder: (context, index) {
            final tool = _tools[index];
            return _OfficeToolTile(
              tool: tool,
              onTap: () => _showPlaceholder(context, tool.title),
            );
          },
        ),
      ],
    );
  }

  void _showPlaceholder(BuildContext context, String name) {
    showAppSnackBar(context, '$name即将上线');
  }
}

class _OfficeFeature extends StatelessWidget {
  const _OfficeFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 112,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Padding(
                      padding: const EdgeInsets.only(right: 44),
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(icon, color: Colors.white, size: 30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OfficeToolTile extends StatelessWidget {
  const _OfficeToolTile({required this.tool, required this.onTap});

  final _OfficeTool tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceSoft,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      tool.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: tool.color.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(tool.icon, color: tool.color, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfficeTool {
  const _OfficeTool(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
  );

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}
