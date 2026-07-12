import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../models/chat_attachment.dart';

class FileAttachmentException implements Exception {
  const FileAttachmentException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FileAttachmentService {
  const FileAttachmentService();

  Future<List<ChatAttachment>> pickFiles({
    required List<String> acceptedExtensions,
    required int maxFiles,
    required int maxFileSizeMb,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: acceptedExtensions.isEmpty ? FileType.any : FileType.custom,
      allowedExtensions: acceptedExtensions.isEmpty ? null : acceptedExtensions,
      allowMultiple: maxFiles > 1,
      withData: true,
    );
    if (result == null) {
      return const [];
    }
    if (result.files.length > maxFiles) {
      throw FileAttachmentException('最多只能选择$maxFiles个文件');
    }

    final maxBytes = maxFileSizeMb * 1024 * 1024;
    final attachments = <ChatAttachment>[];
    for (final file in result.files) {
      if (file.size > maxBytes) {
        throw FileAttachmentException('${file.name}超过${maxFileSizeMb}MB限制');
      }
      final bytes = file.bytes ??
          (file.path == null ? null : await File(file.path!).readAsBytes());
      if (bytes == null) {
        throw FileAttachmentException('${file.name}读取失败');
      }
      final extension = (file.extension ?? _extension(file.name)).toLowerCase();
      attachments.add(
        ChatAttachment(
          id: 'file-${DateTime.now().microsecondsSinceEpoch}-${attachments.length}',
          name: file.name,
          kind: 'FILE',
          type: _mimeType(extension),
          mimeType: _mimeType(extension),
          size: bytes.length,
          status: 'READY',
          base64Data: base64Encode(bytes),
        ),
      );
    }
    return attachments;
  }

  String _extension(String name) {
    final index = name.lastIndexOf('.');
    return index < 0 ? '' : name.substring(index + 1);
  }

  String _mimeType(String extension) {
    return switch (extension) {
      'pdf' => 'application/pdf',
      'docx' =>
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'pptx' =>
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'epub' => 'application/epub+zip',
      'md' || 'txt' => 'text/plain',
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'application/octet-stream',
    };
  }
}
