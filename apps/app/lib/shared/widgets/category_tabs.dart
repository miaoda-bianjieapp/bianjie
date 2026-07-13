import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class CategoryTabs extends StatelessWidget {
  const CategoryTabs({
    required this.items,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: AppSpacing.sm);
        },
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item == selected;

          return ChoiceChip(
            label: Text(item),
            selected: isSelected,
            onSelected: (_) => onSelected(item),
            showCheckmark: false,
            selectedColor: AppColors.primaryBlue,
            backgroundColor: AppColors.card,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            side: BorderSide(
              color: isSelected ? AppColors.primaryBlue : AppColors.border,
            ),
          );
        },
      ),
    );
  }
}
