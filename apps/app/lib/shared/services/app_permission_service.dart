import 'package:permission_handler/permission_handler.dart';

enum AppPermission {
  photos,
}

class AppPermissionState {
  const AppPermissionState({
    required this.permission,
    required this.status,
  });

  final AppPermission permission;
  final PermissionStatus status;

  bool get isGranted => status.isGranted || status.isLimited;

  String get label {
    return switch (permission) {
      AppPermission.photos => '图片访问权限',
    };
  }

  String get description {
    return switch (permission) {
      AppPermission.photos => '用于选择图片作为 AI 提问附件',
    };
  }

  String get statusLabel {
    if (status.isGranted) {
      return '已允许';
    }
    if (status.isLimited) {
      return '部分允许';
    }
    if (status.isPermanentlyDenied) {
      return '需到系统设置开启';
    }
    if (status.isDenied) {
      return '未允许';
    }
    return '未确定';
  }
}

class AppPermissionService {
  const AppPermissionService();

  Future<AppPermissionState> check(AppPermission permission) async {
    return AppPermissionState(
      permission: permission,
      status: await _platformPermission(permission).status,
    );
  }

  Future<AppPermissionState> request(AppPermission permission) async {
    final platformPermission = _platformPermission(permission);
    final current = await platformPermission.status;
    if (current.isPermanentlyDenied) {
      await openAppSettings();
      return AppPermissionState(permission: permission, status: current);
    }
    return AppPermissionState(
      permission: permission,
      status: await platformPermission.request(),
    );
  }

  Permission _platformPermission(AppPermission permission) {
    return switch (permission) {
      AppPermission.photos => Permission.photos,
    };
  }
}
