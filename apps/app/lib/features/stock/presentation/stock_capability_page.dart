import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/snackbar.dart';
import '../../../shared/providers/mock_data_providers.dart';

class StockCapabilityPage extends ConsumerWidget {
  const StockCapabilityPage({
    required this.capabilityId,
    super.key,
  });

  final String capabilityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capabilities = ref.watch(stockCapabilitiesProvider);
    final capability = capabilities.firstWhere(
      (item) => item.id == capabilityId,
      orElse: () => capabilities.first,
    );

    return Scaffold(
      appBar: AppBar(title: Text(capability.title)),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(capability.icon, color: AppColors.primaryBlue, size: 36),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  capability.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(capability.prompt),
                const SizedBox(height: AppSpacing.xl),
                FilledButton.icon(
                  onPressed: () => showAppSnackBar(context, '股票任务占位已创建'),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('创建占位任务'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
