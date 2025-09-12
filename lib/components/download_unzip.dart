import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:archive/archive_io.dart';

import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/em.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class DownloadUnzipDialog extends StatefulWidget {
  final List<String> urls;
  final String dest;

  const DownloadUnzipDialog({
    required this.urls,
    required this.dest,
    super.key,
  });

  @override
  State<DownloadUnzipDialog> createState() => _DownloadUnzipDialogState();
}

enum DStage { downloading, unzipping, done }

class _DownloadUnzipDialogState extends State<DownloadUnzipDialog> {
  late final List<(DStage, double)> progress;

  double _perc(int i) => progress[i].$2;
  DStage _stage(int i) => progress[i].$1;
  // [0,1] -> [0,100]
  double _ntrunc(double x) => (x * 10000).toInt().toDouble() / 100;

  @override
  void initState() {
    super.initState();
    progress = List.generate(
      widget.urls.length,
      (i) => (DStage.downloading, 0),
    );
    _startDownload();
  }

  Future<void> _startDownload() async {
    final tmp = await getTemporaryDirectory();

    for (final (i, url) in widget.urls.indexed) {
      final base = path.basename(url);
      final p = path.join(widget.dest, base);
      if (Directory(p).existsSync() || File(p).existsSync()) {
        setState(() => progress[i] = (DStage.done, 100));
        continue;
      }
      Dio()
          .download(
            url,
            '${tmp.path}/$base',
            onReceiveProgress: (int received, int total) {
              setState(
                () => progress[i] = (progress[i].$1, _ntrunc(received / total)),
              );
            },
          )
          .then((_) async {
            setState(() => progress[i] = (DStage.unzipping, 100));
            await extractFileToDisk(path.join(tmp.path, base), widget.dest);
            setState(() => progress[i] = (DStage.done, 100));
          });
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
      actions: progress.every((b) => b.$1 == DStage.done)
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
    return Row(
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
        if (_stage(index) == DStage.downloading)
          Text(l.download_perc(path.basename(widget.urls[index]), _perc(index)))
        else if (_stage(index) == DStage.unzipping)
          Text(l.download_extracting)
        else
          Text(l.download_done),
      ],
    );
  }
}

void showTileDownloadDialog(
  BuildContext context,
  String prefix,
  String path,
  int maxZoomLevel,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => DownloadUnzipDialog(
      urls: List.generate(
        min(maxZoomLevel, 10) - 3,
        (i) => '$prefix/${i + 4}.zip',
      ),
      dest: path,
    ),
  );
}
