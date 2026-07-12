import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snackbar.dart';
import '../services/artifact_file_service.dart';

class ArtifactAttachmentCard extends StatelessWidget {
  const ArtifactAttachmentCard({
    required this.name,
    required this.kind,
    required this.mimeType,
    required this.base64Data,
    required this.url,
    this.width = 220,
    super.key,
  });

  final String name;
  final String kind;
  final String mimeType;
  final String? base64Data;
  final String? url;
  final double width;

  @override
  Widget build(BuildContext context) {
    if (kind.toUpperCase() == 'IMAGE') {
      final image = _imageWidget();
      if (image != null) {
        return SizedBox(
          width: width,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _openPreview(context),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: image,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sm,
                      AppSpacing.xs,
                      AppSpacing.xs,
                      AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: '打开',
                          icon: const Icon(Icons.open_in_full, size: 18),
                          onPressed: () => _openPreview(context),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: '保存',
                          icon: const Icon(Icons.download_outlined, size: 20),
                          onPressed: () => _save(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_iconFor(kind), size: 18, color: AppColors.primaryBlue),
            const SizedBox(width: AppSpacing.sm),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: width - 70),
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _imageWidget() {
    final normalizedBase64 = _normalizedBase64(base64Data, url);
    if (normalizedBase64 != null) {
      try {
        return Image.memory(
          base64Decode(normalizedBase64),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _imageFallback(),
        );
      } catch (_) {
        return _imageFallback();
      }
    }
    if (url != null && url!.isNotEmpty && !url!.startsWith('data:')) {
      return Image.network(
        url!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _imageFallback(),
      );
    }
    return null;
  }

  void _openPreview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return _ImagePreviewPage(
            name: name,
            mimeType: mimeType,
            base64Data: base64Data,
            url: url,
          );
        },
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    try {
      final bytes = await ArtifactFileService.instance.loadBytes(
        base64Data: base64Data,
        url: url,
      );
      await ArtifactFileService.instance.saveImage(
        name: name,
        mimeType: mimeType,
        bytes: bytes,
      );
      if (context.mounted) {
        showAppSnackBar(context, '图片已保存到系统相册');
      }
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, error.toString());
      }
    }
  }

  IconData _iconFor(String kind) {
    return switch (kind.toUpperCase()) {
      'AUDIO' => Icons.graphic_eq,
      'VIDEO' => Icons.movie_outlined,
      'IMAGE' => Icons.image_outlined,
      _ => Icons.attach_file,
    };
  }
}

class _ImagePreviewPage extends StatelessWidget {
  const _ImagePreviewPage({
    required this.name,
    required this.mimeType,
    required this.base64Data,
    required this.url,
  });

  final String name;
  final String mimeType;
  final String? base64Data;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final image = _previewImage();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: '保存',
            icon: const Icon(Icons.download_outlined),
            onPressed: () => _save(context),
          ),
        ],
      ),
      body: Center(
        child: image == null
            ? const Icon(Icons.broken_image_outlined, color: Colors.white70)
            : InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: image,
              ),
      ),
    );
  }

  Widget? _previewImage() {
    final normalizedBase64 = _normalizedBase64(base64Data, url);
    if (normalizedBase64 != null) {
      try {
        return Image.memory(base64Decode(normalizedBase64),
            fit: BoxFit.contain);
      } catch (_) {
        return null;
      }
    }
    if (url != null && url!.isNotEmpty && !url!.startsWith('data:')) {
      return Image.network(url!, fit: BoxFit.contain);
    }
    return null;
  }

  Future<void> _save(BuildContext context) async {
    try {
      final bytes = await ArtifactFileService.instance.loadBytes(
        base64Data: base64Data,
        url: url,
      );
      await ArtifactFileService.instance.saveImage(
        name: name,
        mimeType: mimeType,
        bytes: bytes,
      );
      if (context.mounted) {
        showAppSnackBar(context, '图片已保存到系统相册');
      }
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, error.toString());
      }
    }
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

Widget _imageFallback() {
  return const ColoredBox(
    color: AppColors.surfaceSoft,
    child: Center(child: Icon(Icons.broken_image_outlined)),
  );
}
