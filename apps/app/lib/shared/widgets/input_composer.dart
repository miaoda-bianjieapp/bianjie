import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class InputComposer extends StatelessWidget {
  const InputComposer({
    required this.controller,
    required this.hintText,
    required this.onSend,
    required this.actions,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSend;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            TextField(
              controller: controller,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
              ),
            ),
            const Divider(color: AppColors.border),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: actions,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                FilledButton(
                  onPressed: onSend,
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                  ),
                  child: const Icon(Icons.arrow_upward),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ComposerActionChip extends StatelessWidget {
  const ComposerActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: AppColors.textSecondary),
      label: Text(label),
      onPressed: onTap,
      side: const BorderSide(color: AppColors.border),
      backgroundColor: AppColors.surface,
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
