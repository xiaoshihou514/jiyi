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

// 匹配类型枚举
enum MatchType { title, transcript }

@DeepSeek()
class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _results = [];
  bool _isLoading = false;
  String _searchQuery = '';

  // 搜索方法
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    try {
      final data = await IO.indexFuture;
      final results = <SearchResult>[];

      for (final entry in data) {
        // 在标题中搜索
        final titleMatchIndex = entry.title.toLowerCase().indexOf(
              query.toLowerCase(),
            );
        if (titleMatchIndex != -1) {
          results.add(
            SearchResult(
              entry: entry,
              matchType: MatchType.title,
              matchPosition: titleMatchIndex,
            ),
          );
          continue;
        }

        // 在转录文本中搜索
        final transcriptLines = entry.transcript.split('\n');
        for (int i = 0; i < transcriptLines.length; i++) {
          final line = transcriptLines[i];
          final lineMatchIndex = line.toLowerCase().indexOf(
                query.toLowerCase(),
              );
          if (lineMatchIndex != -1) {
            results.add(
              SearchResult(
                entry: entry,
                matchType: MatchType.transcript,
                matchPosition: lineMatchIndex,
                transcriptLine: line,
              ),
            );
            break; // 只显示第一个匹配行
          }
        }
      }

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 格式化时长
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // 构建高亮文本
  List<TextSpan> _buildHighlightedText(
    String text,
    int matchIndex,
    String query,
  ) {
    final matchEnd = matchIndex + query.length;

    return [
      if (matchIndex > 0)
        TextSpan(
          text: text.substring(0, matchIndex),
          style: TextStyle(color: DefaultColors.fg),
        ),
      TextSpan(
        text: text.substring(matchIndex, matchEnd),
        style: TextStyle(
          color: DefaultColors.func,
          fontWeight: FontWeight.bold,
        ),
      ),
      if (matchEnd < text.length)
        TextSpan(
          text: text.substring(matchEnd),
          style: TextStyle(color: DefaultColors.fg),
        ),
    ];
  }

  // 构建搜索结果项
  Widget _buildSearchResultItem(SearchResult result, int index) {
    final entry = result.entry;
    final timeStr = DateFormat.Hm().format(entry.time);
    final durationStr = _formatDuration(entry.length);

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
              '${index + 1}',
              style: TextStyle(
                fontFamily: "朱雀仿宋",
                color: DefaultColors.shade_5,
                fontSize: 6.em,
              ),
            ),
          ),

          // 封面
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
              child: Text(
                entry.cover,
                style: TextStyle(fontFamily: "朱雀仿宋", fontSize: 7.5.em),
              ),
            ),
          ),

          // 文本信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题（带高亮）
                RichText(
                  text: TextSpan(
                    children: result.matchType == MatchType.title
                        ? _buildHighlightedText(
                            entry.title,
                            result.matchPosition,
                            _searchQuery,
                          )
                        : [
                            TextSpan(
                              text: entry.title,
                              style: TextStyle(
                                fontFamily: "朱雀仿宋",
                                color: DefaultColors.fg,
                                fontSize: 7.em,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.em),

                // 匹配内容展示
                if (result.matchType == MatchType.transcript)
                  RichText(
                    text: TextSpan(
                      children: _buildHighlightedText(
                        result.transcriptLine ?? '',
                        result.matchPosition,
                        _searchQuery,
                      ),
                      style: TextStyle(
                        fontFamily: "朱雀仿宋",
                        color: DefaultColors.fg,
                        fontSize: 6.em,
                      ),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                // 时间信息
                Text(
                  result.matchType == MatchType.title
                      ? '$timeStr · $durationStr'
                      : '$timeStr · $durationStr',
                  style: TextStyle(
                    fontFamily: "朱雀仿宋",
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

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
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l.search_hint,
              hintStyle: TextStyle(
                fontFamily: "朱雀仿宋",
                color: DefaultColors.shade_5,
              ),
              border: InputBorder.none,
            ),
            style: TextStyle(
              fontFamily: "朱雀仿宋",
              color: DefaultColors.fg,
              fontSize: 7.em,
            ),
            onChanged: _performSearch,
            autofocus: true,
          ),
        ),
      ),
      body: Column(
        children: [
          // 搜索结果计数
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.em, horizontal: 6.em),
              child: Row(
                children: [
                  Icon(Icons.search, color: DefaultColors.func, size: 10.em),
                  SizedBox(width: 4.em),
                  Text(
                    l.search_results_count(_results.length, _searchQuery),
                    style: TextStyle(
                      fontFamily: "朱雀仿宋",
                      color: DefaultColors.fg,
                      fontSize: 8.em,
                    ),
                  ),
                ],
              ),
            ),

          // 加载指示器
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(8.em),
                child: CircularProgressIndicator(color: DefaultColors.func),
              ),
            ),

          // 搜索结果列表
          if (!_isLoading && _results.isNotEmpty)
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 6.em),
                itemCount: _results.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 4.em, color: DefaultColors.shade_3),
                itemBuilder: (context, index) =>
                    _buildSearchResultItem(_results[index], index),
              ),
            ),

          // 无结果提示
          if (!_isLoading && _searchQuery.isNotEmpty && _results.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  l.search_no_results,
                  style: TextStyle(
                    fontFamily: "朱雀仿宋",
                    color: DefaultColors.shade_5,
                    fontSize: 8.em,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 搜索结果模型
class SearchResult {
  final Metadata entry;
  final MatchType matchType;
  final int matchPosition;
  final String? transcriptLine;

  SearchResult({
    required this.entry,
    required this.matchType,
    required this.matchPosition,
    this.transcriptLine,
  });
}
