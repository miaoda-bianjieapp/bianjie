import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../models/chat_attachment.dart';
import 'app_permission_service.dart';

class ImageAttachmentException implements Exception {
  const ImageAttachmentException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ImageAttachmentService {
  ImageAttachmentService({
    ImagePicker? picker,
    AppPermissionService permissionService = const AppPermissionService(),
  })  : _picker = picker ?? ImagePicker(),
        _permissionService = permissionService;

  static const int maxOriginalBytes = 12 * 1024 * 1024;
  static const int maxEncodedBytes = 900 * 1024;
  static const int maxDimension = 1280;

  final ImagePicker _picker;
  final AppPermissionService _permissionService;

  Future<ChatAttachment?> pickImage() async {
    final permission = await _permissionService.request(AppPermission.photos);
    if (!permission.isGranted) {
      throw const ImageAttachmentException('请先允许图片访问权限');
    }

    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return null;
    }

    final bytes = await picked.readAsBytes();
    if (bytes.length > maxOriginalBytes) {
      throw const ImageAttachmentException('图片过大，请选择 12MB 以内的图片');
    }

    final processed = _process(bytes);
    return ChatAttachment(
      id: 'image-${DateTime.now().microsecondsSinceEpoch}',
      name: picked.name,
      kind: 'IMAGE',
      type: 'image/jpeg',
      mimeType: 'image/jpeg',
      size: processed.length,
      status: 'READY',
      base64Data: base64Encode(processed),
    );
  }

  Uint8List _process(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const ImageAttachmentException('图片格式暂不支持');
    }

    final resized = _resize(decoded);
    final flattened = img.Image(
      width: resized.width,
      height: resized.height,
      numChannels: 3,
    );
    img.fill(flattened, color: img.ColorRgb8(255, 255, 255));
    img.compositeImage(flattened, resized);

    for (final quality in [86, 78, 70, 62, 54]) {
      final encoded = Uint8List.fromList(
        img.encodeJpg(flattened, quality: quality),
      );
      if (encoded.length <= maxEncodedBytes || quality == 54) {
        if (encoded.length > maxEncodedBytes) {
          throw const ImageAttachmentException('压缩后仍超过限制，请换一张更小的图片');
        }
        return encoded;
      }
    }
    throw const ImageAttachmentException('图片处理失败');
  }

  img.Image _resize(img.Image image) {
    final longest = image.width > image.height ? image.width : image.height;
    if (longest <= maxDimension) {
      return image;
    }
    if (image.width >= image.height) {
      return img.copyResize(image, width: maxDimension);
    }
    return img.copyResize(image, height: maxDimension);
  }
}
