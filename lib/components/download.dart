import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/em.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FileDownloadDialog extends StatefulWidget {
  final List<String> urls;
  final String? destinationDirectory;
  final List<String>? fileNames;

  const FileDownloadDialog({
    required this.urls,
    this.destinationDirectory,
    this.fileNames,
    super.key,
  });

  @override
  State<FileDownloadDialog> createState() => _FileDownloadDialogState();
}

enum DownloadStage { downloading, done }

class _FileDownloadDialogState extends State<FileDownloadDialog> {
  late final List<(DownloadStage, double)> progress;
  late final List<String> fileNames;
  late final String destDir;

  double _perc(int i) => progress[i].$2;
  DownloadStage _stage(int i) => progress[i].$1;
  // [0,1] -> [0,100]
  double _ntrunc(double x) => (x * 10000).toInt().toDouble() / 100;

  @override
  void initState() {
    super.initState();

    // 初始化进度列表
    progress = List.generate(
      widget.urls.length,
      (i) => (DownloadStage.downloading, 0),
    );

    // 处理文件名
    fileNames =
        widget.fileNames ??
        widget.urls.map((url) => path.basename(url)).toList();

    // 确定目标目录
    _determineDestination().then((_) => _startDownload());
  }

  Future<void> _determineDestination() async {
    if (widget.destinationDirectory != null) {
      destDir = widget.destinationDirectory!;
      // 确保目录存在
      await Directory(destDir).create(recursive: true);
    } else {
      // 使用临时目录
      final tmp = await getTemporaryDirectory();
      destDir = tmp.path;
    }
  }

  Future<void> _startDownload() async {
    for (int i = 0; i < widget.urls.length; i++) {
      final url = widget.urls[i];
      final fileName = fileNames[i];
      final savePath = path.join(destDir, fileName);

      // 检查文件是否已存在
      if (File(savePath).existsSync()) {
        setState(() => progress[i] = (DownloadStage.done, 100));
        continue;
      }

      await Dio().download(
        url,
        savePath,
        onReceiveProgress: (int received, int total) {
          setState(
            () => progress[i] = (
              DownloadStage.downloading,
              _ntrunc(received / total),
            ),
          );
        },
      );

      setState(() => progress[i] = (DownloadStage.done, 100));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: DefaultColors.bg,
      titleTextStyle: TextStyle(
        decoration: TextDecoration.none,
        color: DefaultColors.fg,
        fontFamily: "朱雀仿宋",
        fontSize: 8.em,
      ),
      title: Text(l.download_title),
      actions: progress.every((b) => b.$1 == DownloadStage.done)
          ? [
              TextButton(
                onPressed: () => {
                  if (mounted) {Navigator.of(context).pop(false)},
                },
                child: Text(
                  l.download_exit,
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    color: DefaultColors.constant,
                    fontFamily: "朱雀仿宋",
                    fontSize: 5.em,
                  ),
                ),
              ),
            ]
          : null,
      content: Padding(
        padding: EdgeInsets.all(3.em),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            decoration: TextDecoration.none,
            color: DefaultColors.fg,
            fontFamily: "朱雀仿宋",
            fontSize: 4.em,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.urls.length, (i) => _progressViz(i)),
          ),
        ),
      ),
    );
  }

  Widget _progressViz(int index) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.em),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fileNames[index],
            style: TextStyle(fontSize: 3.5.em),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 0.5.em),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 2.em,
                width: 10.em,
                child: LinearProgressIndicator(
                  value: _perc(index) / 100,
                  backgroundColor: DefaultColors.shade_4,
                  valueColor: AlwaysStoppedAnimation(DefaultColors.constant),
                ),
              ),
              if (_stage(index) == DownloadStage.downloading)
                Text(l.download_perc(index + 1, _perc(index)))
              else
                Text(l.download_done),
            ],
          ),
        ],
      ),
    );
  }
}

void showFileDownloadDialog(
  BuildContext context,
  List<String> urls, {
  String? destinationDirectory,
  List<String>? fileNames,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => FileDownloadDialog(
      urls: urls,
      destinationDirectory: destinationDirectory,
      fileNames: fileNames,
    ),
  );
}
