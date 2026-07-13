import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme_provider.dart';
import '../../../core/utils/snackbar.dart';
import '../../../shared/providers/permission_providers.dart';
import '../../../shared/services/app_permission_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _teenModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final visualTheme = ref.watch(appVisualThemeProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
          children: [
            Text(
              '设置',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 34,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 56),
            _SettingsRow(
              icon: Icons.image_outlined,
              title: '设置对话头像',
              trailing: CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryBlue.withOpacity(0.12),
                child: Text(
                  'BJ',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              onTap: () => showAppSnackBar(context, '对话头像设置占位'),
            ),
            _SettingsRow(
              icon: visualTheme == AppVisualTheme.night
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              title: '外观模式',
              subtitle: visualTheme == AppVisualTheme.night ? '夜航模式' : '黑白日间模式',
              trailing: Switch(
                value: visualTheme == AppVisualTheme.night,
                onChanged: (isNight) {
                  ref.read(appVisualThemeProvider.notifier).state =
                      isNight ? AppVisualTheme.night : AppVisualTheme.signal;
                },
              ),
            ),
            _SettingsRow(
              icon: Icons.admin_panel_settings_outlined,
              title: '权限管理',
              onTap: _showPermissionSheet,
            ),
            _SettingsRow(
              icon: Icons.settings_applications_outlined,
              title: '保持应用后台运行',
              onTap: () => showAppSnackBar(context, '后台运行设置占位'),
            ),
            _SettingsRow(
              icon: Icons.extension_outlined,
              title: '小组件设置',
              onTap: () => showAppSnackBar(context, '小组件设置占位'),
            ),
            _SettingsRow(
              icon: Icons.tune_outlined,
              title: '对话偏好设置',
              onTap: () => showAppSnackBar(context, '对话偏好占位'),
            ),
            _SettingsRow(
              icon: Icons.notifications_none,
              title: '通知栏通知',
              onTap: () => showAppSnackBar(context, '通知栏通知占位'),
            ),
            _SettingsRow(
              icon: Icons.volume_up_outlined,
              title: '声音通知',
              onTap: () => showAppSnackBar(context, '声音通知占位'),
            ),
            _SettingsRow(
              icon: Icons.widgets_outlined,
              title: '版本更新',
              value: '检查更新',
              onTap: () => showAppSnackBar(context, '当前已是 Demo 最新版本'),
            ),
            _SettingsRow(
              icon: Icons.visibility_outlined,
              title: '清除缓存',
              value: '29.14MB',
              onTap: () => showAppSnackBar(context, '缓存清理占位'),
            ),
            _SettingsRow(
              icon: Icons.reply_outlined,
              title: '分享 App 给好友',
              onTap: () => showAppSnackBar(context, '分享 App 占位'),
            ),
            _SettingsRow(
              icon: Icons.face_6_outlined,
              title: '青少年保护模式',
              subtitle: '限制每日使用30分钟，保护青少年健康使用',
              trailing: Switch(
                value: _teenModeEnabled,
                onChanged: (value) {
                  setState(() => _teenModeEnabled = value);
                  showAppSnackBar(
                    context,
                    value ? '已开启青少年保护模式' : '已关闭青少年保护模式',
                  );
                },
              ),
            ),
            _SettingsRow(
              icon: Icons.phone_in_talk_outlined,
              title: '联系客服',
              onTap: () => showAppSnackBar(context, '联系客服占位'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPermissionSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final photoPermission = ref.watch(photoPermissionProvider);
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '权限管理',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  photoPermission.when(
                    data: (state) => _PermissionTile(
                      state: state,
                      onRequest: () async {
                        final next = await ref
                            .read(appPermissionServiceProvider)
                            .request(AppPermission.photos);
                        ref.invalidate(photoPermissionProvider);
                        if (context.mounted) {
                          showAppSnackBar(context, next.statusLabel);
                        }
                      },
                    ),
                    loading: () => const LinearProgressIndicator(minHeight: 3),
                    error: (error, _) => Text(error.toString()),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.state,
    required this.onRequest,
  });

  final AppPermissionState state;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.photo_library_outlined),
      title: Text(state.label),
      subtitle: Text(state.description),
      trailing: TextButton(
        onPressed: state.isGranted ? null : onRequest,
        child: Text(state.statusLabel),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final trailingWidget = trailing ??
        (value == null
            ? Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 30,
              )
            : Text(
                value!,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          crossAxisAlignment: subtitle == null
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 44,
              child: Icon(
                icon,
                color: AppColors.textSecondary,
                size: 30,
              ),
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 23,
                      height: 1.15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            trailingWidget,
          ],
        ),
      ),
    );
  }
}
