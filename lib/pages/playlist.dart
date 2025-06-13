import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/pages/player.dart';
import 'package:jiyi/utils/anno.dart';
import 'package:jiyi/utils/em.dart';
import 'package:jiyi/utils/io.dart';
import 'package:jiyi/utils/metadata.dart';
import 'package:jiyi/utils/smooth_router.dart';
import 'package:jiyi/utils/text_color.dart';

@DeepSeek()
class Playlist extends StatefulWidget {
  final DateTime _day;
  const Playlist(this._day, {super.key});

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  List<Metadata> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = IO.metadataByDay(widget._day);
    setState(() => _entries = entries);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final dateStr = DateFormat('yyyy.MM.dd').format(widget._day);

    return Scaffold(
      backgroundColor: DefaultColors.bg,
      appBar: AppBar(
        backgroundColor: DefaultColors.bg,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Padding(
            padding: EdgeInsets.all(2.em),
            child: Icon(Icons.arrow_back, color: DefaultColors.fg, size: 8.em),
          ),
        ),
        title: Padding(
          padding: EdgeInsets.only(top: 4.em),
          child: Text(
            dateStr,
            style: TextStyle(color: DefaultColors.fg, fontSize: 8.em),
          ),
        ),
      ),
      body: Column(
        children: [
          // 日志列表标题
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.em, horizontal: 6.em),
            child: Row(
              children: [
                Icon(Icons.list, color: DefaultColors.func, size: 10.em),
                SizedBox(width: 4.em),
                Text(
                  l.playlist_title(_entries.length),
                  style: TextStyle(
                    color: DefaultColors.fg,
                    fontSize: 8.em,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 日志列表
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 6.em),
              itemCount: _entries.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 4.em, color: DefaultColors.shade_3),
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return _buildLogItem(entry, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(Metadata entry, int number) {
    final timeStr = DateFormat.Hm().format(entry.time);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.em, vertical: 4.em),
      margin: EdgeInsets.only(bottom: 3.em),
      decoration: BoxDecoration(
        color: DefaultColors.shade_1,
        borderRadius: BorderRadius.circular(8.em),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 序号
          Container(
            width: 8.em,
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: TextStyle(color: DefaultColors.shade_5, fontSize: 6.em),
            ),
          ),

          // 封面容器
          Container(
            width: 15.em,
            height: 15.em,
            margin: EdgeInsets.symmetric(horizontal: 4.em),
            decoration: BoxDecoration(
              color: getStatusColor(entry.cover),
              shape: BoxShape.circle,
              border: Border.all(color: DefaultColors.shade_4, width: 0.5.em),
            ),
            child: Center(
              child: Text(entry.cover, style: TextStyle(fontSize: 7.5.em)),
            ),
          ),

          // 文本信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title.isNotEmpty ? entry.title : '未命名记录',
                  style: TextStyle(
                    color: DefaultColors.fg,
                    fontSize: 7.em,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.em),
                Text(
                  '$timeStr · ${_formatDuration(entry.length)}',
                  style: TextStyle(
                    color: DefaultColors.shade_5,
                    fontSize: 6.em,
                  ),
                ),
              ],
            ),
          ),

          // 播放按钮
          IconButton(
            icon: Icon(
              Icons.play_circle_filled,
              color: DefaultColors.func,
              size: 15.em,
            ),
            onPressed: () =>
                Navigator.push(context, SmoothRouter.builder(Player(entry))),
          ),
        ],
      ),
    );
  }
}
