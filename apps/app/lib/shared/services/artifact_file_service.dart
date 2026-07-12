import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

class ArtifactFileException implements Exception {
  const ArtifactFileException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ArtifactFileService {
  ArtifactFileService._();

  static final ArtifactFileService instance = ArtifactFileService._();

  static const MethodChannel _channel =
      MethodChannel('com.bianjie.ai.bianjie_ai_app/artifacts');

  Future<Uint8List> loadBytes({
    required String? base64Data,
    required String? url,
  }) async {
    final normalizedBase64 = _normalizedBase64(base64Data, url);
    if (normalizedBase64 != null) {
      try {
        return base64Decode(normalizedBase64);
      } catch (_) {
        throw const ArtifactFileException('附件数据解析失败');
      }
    }
    if (url == null || url.isEmpty || url.startsWith('data:')) {
      throw const ArtifactFileException('附件暂无可保存的数据');
    }
    return _download(url);
  }

  Future<String> saveImage({
    required String name,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    final result = await _channel.invokeMethod<String>('saveImageToGallery', {
      'name': _safeFileName(name, 'png'),
      'mimeType': mimeType.isEmpty ? 'image/png' : mimeType,
      'bytes': bytes,
    });
    return result ?? name;
  }

  Future<Uint8List> _download(String url) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ArtifactFileException('附件下载失败：${response.statusCode}');
      }
      final chunks = <int>[];
      await for (final chunk in response) {
        chunks.addAll(chunk);
      }
      if (chunks.isEmpty) {
        throw const ArtifactFileException('附件下载结果为空');
      }
      return Uint8List.fromList(chunks);
    } on ArtifactFileException {
      rethrow;
    } catch (_) {
      throw const ArtifactFileException('附件下载失败，请稍后重试');
    } finally {
      client.close(force: true);
    }
  }

  String? _normalizedBase64(String? base64Data, String? url) {
    if (base64Data != null && base64Data.isNotEmpty) {
      return base64Data;
    }
    if (url == null || !url.startsWith('data:')) {
      return null;
    }
    final commaIndex = url.indexOf(',');
    if (commaIndex < 0 || commaIndex == url.length - 1) {
      return null;
    }
    return url.substring(commaIndex + 1);
  }

  String _safeFileName(String name, String fallbackExtension) {
    final sanitized = name
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
    final fileName = sanitized.isEmpty
        ? 'bianjie_${DateTime.now().millisecondsSinceEpoch}.$fallbackExtension'
        : sanitized;
    return fileName.contains('.') ? fileName : '$fileName.$fallbackExtension';
  }
}
