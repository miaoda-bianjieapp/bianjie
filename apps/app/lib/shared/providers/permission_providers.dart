import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/app_permission_service.dart';
import '../services/file_attachment_service.dart';
import '../services/image_attachment_service.dart';

final appPermissionServiceProvider = Provider<AppPermissionService>((ref) {
  return const AppPermissionService();
});

final imageAttachmentServiceProvider = Provider<ImageAttachmentService>((ref) {
  return ImageAttachmentService(
    permissionService: ref.watch(appPermissionServiceProvider),
  );
});

final fileAttachmentServiceProvider = Provider<FileAttachmentService>((ref) {
  return const FileAttachmentService();
});

final photoPermissionProvider =
    FutureProvider.autoDispose<AppPermissionState>((ref) {
  return ref.watch(appPermissionServiceProvider).check(AppPermission.photos);
});
