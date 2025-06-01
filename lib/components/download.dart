import 'dart:math';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:archive/archive_io.dart';

import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/em.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class DownloadUnzipDialog extends StatefulWidget {
  final String prefix;
  final String dest;
  final int maxZoom;

  const DownloadUnzipDialog({
    required this.prefix,
    required this.dest,
    required this.maxZoom,
    super.key,
  });

  @override
  State<DownloadUnzipDialog> createState() => _DownloadUnzipDialogState();
}

enum DStage { downloading, unzipping, done }

class _DownloadUnzipDialogState extends State<DownloadUnzipDialog> {
  late final List<(DStage, double)> progress;

  double _perc(int i) => progress[i - 4].$2;
  DStage _stage(int i) => progress[i - 4].$1;
  // [0,1] -> [0,100]
  double _ntrunc(double x) => (x * 10000).toInt().toDouble() / 100;

  @override
  void initState() {
    super.initState();
    progress = List.generate(
      widget.maxZoom - 3,
      (i) => (DStage.downloading, 0),
    );
    _startDownload();
  }

  Future<void> _startDownload() async {
    for (int i = 4; i <= widget.maxZoom; i++) {
      final task = DownloadTask(
        url: "${widget.prefix}/$i.zip",
        filename: "$i.zip",
        baseDirectory: BaseDirectory.temporary,
        updates: Updates.statusAndProgress,
        requiresWiFi: true,
        retries: 5,
        allowPause: true,
      );

      FileDownloader()
          .download(
            task,
            onProgress: (x) => setState(
              () => progress[i - 4] = (progress[i - 4].$1, _ntrunc(x)),
            ),
            onStatus: (_) {},
          )
          .then((_) async {
            setState(() => progress[i - 4] = (DStage.unzipping, 100));
            await extractFileToDisk(
              path.join((await getTemporaryDirectory()).path, "$i.zip"),
              widget.dest,
            );
            setState(() => progress[i - 4] = (DStage.done, 100));
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
                child: Text.rich(
                  TextSpan(
                    text: l.download_exit,
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: DefaultColors.constant,
                      fontFamily: "朱雀仿宋",
                      fontSize: 5.em,
                    ),
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
            children: List.generate(
              widget.maxZoom - 3,
              (i) => _progressViz(i + 4),
            ),
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
          Text(l.download_perc(index, _perc(index)))
        else if (_stage(index) == DStage.unzipping)
          Text(l.download_extracting)
        else
          Text(l.download_done),
      ],
    );
  }
}

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
      dest: path,
      maxZoom: min(maxZoomLevel, 10),
    ),
  );
}
