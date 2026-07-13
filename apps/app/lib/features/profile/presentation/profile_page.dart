import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/snackbar.dart';
import '../../../shared/providers/mock_data_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xxl,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryBlue,
                    child: Text(
                      user.avatar,
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.nickname,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(user.phoneMasked),
                        const SizedBox(height: AppSpacing.xs),
                        Text('积分 ${user.points} · ${user.vipStatus}'),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: user.checkedInToday
                        ? null
                        : () {
                            ref.read(userProfileProvider.notifier).checkIn();
                            showAppSnackBar(context, '签到成功，积分 +20');
                          },
                    child: Text(user.checkedInToday ? '已签到' : '签到'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Material(
            color: AppColors.featuredSurface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              onTap: () => context.push('/membership'),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  children: [
                    Icon(
                      Icons.workspace_premium,
                      color: AppColors.warning,
                      size: 34,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        '开通 VIP 会员',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _QuickEntry(
                icon: Icons.person_pin_outlined,
                label: '个人中心',
                onTap: () => context.push('/placeholder/profile-center'),
              ),
              _QuickEntry(
                icon: Icons.workspace_premium_outlined,
                label: '开通会员',
                onTap: () => context.push('/membership'),
              ),
              _QuickEntry(
                icon: Icons.support_agent,
                label: '联系我们',
                onTap: () => context.push('/placeholder/contact'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...[
            ('设置', Icons.settings_outlined, 'settings'),
            ('协议', Icons.description_outlined, 'agreement'),
            ('关于应用', Icons.info_outline, 'about'),
            ('证照信息', Icons.verified_outlined, 'license'),
            ('交流群', Icons.groups_outlined, 'community'),
            ('分享 App', Icons.ios_share, 'share'),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                tileColor: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                leading: Icon(item.$2, color: AppColors.primaryBlue),
                title: Text(item.$1),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  if (item.$3 == 'share') {
                    showAppSnackBar(context, '分享 App 占位反馈');
                  } else if (item.$3 == 'settings') {
                    context.push('/settings');
                  } else {
                    context.push('/placeholder/${item.$3}');
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickEntry extends StatelessWidget {
  const _QuickEntry({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Material(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.lg,
                horizontal: AppSpacing.sm,
              ),
              child: Column(
                children: [
                  Icon(icon, color: AppColors.primaryBlue),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
