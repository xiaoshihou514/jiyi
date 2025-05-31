import 'dart:math';
import 'package:flutter/material.dart';

class DownloadUnzipDialog extends StatefulWidget {
  final String prefix;
  final String path;
  final int maxZoom;

  const DownloadUnzipDialog({
    required this.prefix,
    required this.path,
    required this.maxZoom,
    super.key,
  });

  @override
  State<DownloadUnzipDialog> createState() => _DownloadUnzipDialogState();
}

class _DownloadUnzipDialogState extends State<DownloadUnzipDialog> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

// 使用示例
void showDownloadDialog(
  BuildContext context,
  String prefix,
  String path,
  int maxZoomLevel,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => DownloadUnzipDialog(
      prefix: prefix,
      path: path,
      maxZoom: max(maxZoomLevel, 10),
    ),
  );
}
