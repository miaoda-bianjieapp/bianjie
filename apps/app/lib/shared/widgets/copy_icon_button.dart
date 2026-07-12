import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/snackbar.dart';

class CopyIconButton extends StatelessWidget {
  const CopyIconButton({
    required this.text,
    this.color,
    this.copiedMessage = '已复制到剪贴板',
    super.key,
  });

  final String text;
  final Color? color;
  final String copiedMessage;

  @override
  Widget build(BuildContext context) {
    final canCopy = text.trim().isNotEmpty;
    return IconButton(
      tooltip: '复制',
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 34, height: 34),
      padding: const EdgeInsets.all(6),
      color: color,
      icon: const Icon(Icons.copy_outlined, size: 18),
      onPressed: canCopy ? () => _copy(context) : null,
    );
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      showAppSnackBar(context, copiedMessage);
    }
  }
}
