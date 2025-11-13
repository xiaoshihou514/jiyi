// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoder_offline/geocoder_offline.dart';
import 'package:jiyi/components/download_unzip.dart';
import 'package:jiyi/components/yes_no.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/anno.dart';
import 'package:jiyi/utils/data/llm_setting.dart';
import 'package:jiyi/utils/em.dart';
import 'package:jiyi/utils/geocoder.dart';
import 'package:jiyi/utils/io.dart';
import 'package:jiyi/utils/llm.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

const GEO_DATA = "cities15000.txt";
const HEADERS =
    "geonameid\tname\tasciiname\talternatenames\tlatitude\tlongitude\tfeature class\tfeature code\tcountry code\tcc2\tadmin1 code\tadmin2 code\tadmin3 code\tadmin4 code\tpopulation\televation\tdem\ttimezone\tmodification date\n";
const double _GRAPH_EDGE_THRESHOLD = 0.7;
const double _DETAIL_REQUEST_THRESHOLD = _GRAPH_EDGE_THRESHOLD;
const double _MEANINGFUL_SCORE_THRESHOLD = 0.4;

@DeepSeek()
class Imagine extends StatefulWidget {
  const Imagine({super.key});

  @override
  State<Imagine> createState() => _ImagineState();
}

class _ImagineState extends State<Imagine> {
  late LLMSetting _llmSetting;
  bool _isAnalyzing = false;
  final Map<DateTime, List<String>> _recordingsClues = {};
  final List<_RecordingEdge> _graphEdges = [];
  final Map<DateTime, List<_RecordingEdge>> _graphAdjacency = {};
  final Map<String, _GraphNodeInfo> _graphNodeInfos = {};
  final List<_ImagineMessage> _messages = [];
  final ScrollController _chatScrollController = ScrollController();
  int _messageCounter = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await ss.read(key: ss.LLM_MODEL_SETTINGS);
    setState(() => _llmSetting = LLMSetting.fromJson(settings!));
  }

  @override
  void dispose() {
    _chatScrollController.dispose();
    super.dispose();
  }

  Future<void> analyzePairwiseConnections(BuildContext context) async {
    if (_isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
      _recordingsClues.clear();
      _graphEdges.clear();
      _graphAdjacency.clear();
      _graphNodeInfos.clear();
      _messages.clear();
    });

    _emitCodexUpdate("开始分析录音关联");

    final l = AppLocalizations.of(context)!;
    final mds = await IO.indexFuture;
    final dest = (await getApplicationSupportDirectory()).path;
    final geocoder = GeocodeData(
      HEADERS + File(path.join(dest, GEO_DATA)).readAsStringSync(),
      'alternatenames',
      'name',
      'latitude',
      'longitude',
      fieldDelimiter: '\t',
      eol: '\n',
    );

    // 按时间排序录音
    mds.sort((a, b) => a.time.compareTo(b.time));

    if (mds.length < 2) {
      _emitCodexUpdate("需要至少两个录音才能进行分析");
      setState(() {
        _isAnalyzing = false;
      });
      return;
    }

    final scoringSystemPrompt = """
你是一名“故事线侦测员”，目标是在按时间排列的录音之间寻找同一主题的连续剧情。请只关注能串联故事的发展，而不是抽象或泛泛的相似点，并计算0-1的故事线得分。

判定指南：
- 强故事线 (>=0.7)：两段录音围绕同一问题/计划/人物推进，出现事件延续或情绪/决策的明显承接
- 中等故事线 (0.4-0.7)：主题一致但缺少明确进展，或只在部分细节上保持连续
- 弱故事线 (<0.4)：仅有背景相似、抽象价值观或常见情绪，不构成剧情延伸

此阶段仅需输出 {"score": number} 的 JSON。
""";

    final detailSystemPrompt = """
你继续扮演故事线侦测员。当得分较高时，请说明为什么两个时间上相邻的录音属于同一个故事线：标签要具体描述该故事线的主题，解释需指出事件如何承接。
输出请严格遵循两行，并保持中文：
clue: 2-8字的故事线名称（例如“毕业申请推进”）
exp: 简述上一段内容如何延续到下一段，体现剧情连贯性
""";

    int analysisCount = 0;
    int meaningfulConnectionCount = 0;
    int strongConnectionCount = 0;
    final int totalPairs = (mds.length * (mds.length - 1)) ~/ 2;

    // 两个循环逐个关联分析
    for (int i = 0; i < mds.length; i++) {
      for (int j = i + 1; j < mds.length; j++) {
        final md1 = mds[i];
        final md2 = mds[j];

        final place1 =
            Geocoder.placeOf(geocoder, md1, l.localeName) ??
            l.imagine_unknown_place;
        final place2 =
            Geocoder.placeOf(geocoder, md2, l.localeName) ??
            l.imagine_unknown_place;

        // 获取已有线索
        final existingClues1 = _recordingsClues[md1.time] ?? [];
        final existingClues2 = _recordingsClues[md2.time] ?? [];
        final allExistingClues = [
          ...existingClues1,
          ...existingClues2,
        ].join('; ');

        final pairContext =
            """
录音对比 ${analysisCount + 1}/$totalPairs:

【录音 A - 较早的】
时间：${md1.time.year}年${md1.time.month}月${md1.time.day}日
地点：$place1
内容：${md1.transcript}

【录音 B - 较晚的】
时间：${md2.time.year}年${md2.time.month}月${md2.time.day}日
地点：$place2
内容：${md2.transcript}

时间间隔：${md2.time.difference(md1.time).inDays}天

${allExistingClues.isNotEmpty ? "已有线索: $allExistingClues" : ""}
""";

        final pairIndex = analysisCount + 1;
        final pairLabel = "第$pairIndex 对";
        final pairOrderLabel = "$pairIndex/$totalPairs";
        final resultMessage = _addMessage(
          isUser: false,
          title: "分析进度",
          content: "分析 $pairLabel（共 $totalPairs）计算中…",
          isStreaming: true,
        );

        try {
          final scoringRequest = await Llm.chatWithJsonSchema(
            systemPrompt: scoringSystemPrompt,
            userPrompt:
                """
$pairContext

请先仅给出关联度评分，输出 {"score": number}。
""",
            schema: {
              'type': 'object',
              'properties': {
                'score': {'type': 'number', 'description': '关联度评分 (0-1)'},
              },
              'required': ['score'],
            },
          );
          final scoreJson = scoringRequest.json;

          if (scoreJson != null) {
            final rawScore = scoreJson['score'];
            final connectionScore = rawScore is num ? rawScore.toDouble() : 0.0;

            final pulseLabel =
                "分析 $pairLabel 分数 ${connectionScore.toStringAsFixed(2)}（$pairOrderLabel）";
            _setMessageContent(resultMessage.id, pulseLabel);

            if (connectionScore >= _MEANINGFUL_SCORE_THRESHOLD) {
              meaningfulConnectionCount++;

              if (connectionScore >= _DETAIL_REQUEST_THRESHOLD) {
                _appendToMessage(resultMessage.id, "\n分数较高，正在获取线索…");

                final detailPrompt =
                    """
$pairContext

上一阶段评分为 ${connectionScore.toStringAsFixed(2)}，仅当评分较高时才会请求线索。
请严格按照以下两行输出，不要添加其他说明：
clue: 2-8个字的概括标签
exp: 一句话解释评分原因
""";

                final detailResult = await _streamDetailResponse(
                  messageId: resultMessage.id,
                  systemPrompt: detailSystemPrompt,
                  userPrompt: detailPrompt,
                );

                if (detailResult != null) {
                  final clue = detailResult.clue;
                  final explanation = detailResult.explanation;

                  if (clue.isNotEmpty) {
                    _attachClue(md1.time, clue);
                    _attachClue(md2.time, clue);
                  }

                  if (connectionScore > _GRAPH_EDGE_THRESHOLD) {
                    strongConnectionCount++;
                    _registerGraphEdge(
                      from: md1.time,
                      to: md2.time,
                      score: connectionScore,
                      clue: clue,
                      explanation: explanation,
                    );
                    _appendToMessage(
                      resultMessage.id,
                      "\n已记录图连线 ${_formatMonthDay(md1.time)} → ${_formatMonthDay(md2.time)}",
                    );
                  }
                }
              } else {
                _removeMessage(resultMessage.id);
              }
            } else {
              _removeMessage(resultMessage.id);
            }
          } else {
            _setMessageContent(
              resultMessage.id,
              "分析 $pairLabel 分数解析失败：${scoringRequest.rawResponse ?? '无返回内容'}",
            );
          }

          analysisCount++;

          // 短暂延迟，避免请求过于频繁
          await Future.delayed(Duration(milliseconds: 500));
        } catch (e) {
          _setMessageContent(resultMessage.id, "分析 $pairLabel 出现异常：$e");
        } finally {
          _setMessageStreaming(resultMessage.id, false);
        }
      }
    }

    final summary = StringBuffer()
      ..writeln("=== 分析完成 ===")
      ..writeln("总共分析了 $analysisCount 对录音关联")
      ..writeln("发现 $meaningfulConnectionCount 对中高关联度录音")
      ..writeln(
        "其中 $strongConnectionCount 对满足图构建阈值（>${_GRAPH_EDGE_THRESHOLD.toStringAsFixed(1)}）",
      )
      ..writeln("低关联度录音对已跳过详细分析");

    if (_graphEdges.isNotEmpty) {
      summary.writeln("\n=== 图结构预览 ===");
      for (final edge in _graphEdges) {
        summary.write(edge.describe());
      }
    } else {
      summary.writeln("\n暂无可构建的高关联图边");
    }

    _addMessage(isUser: false, title: '分析总结', content: summary.toString());

    setState(() => _isAnalyzing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DefaultColors.bg,
      appBar: AppBar(
        backgroundColor: DefaultColors.bg,
        foregroundColor: DefaultColors.fg,
        automaticallyImplyLeading: true,
        title: const SizedBox.shrink(),
        elevation: 0,
      ),
      body: Column(
        children: [
          if (_isAnalyzing)
            LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation(DefaultColors.special),
              backgroundColor: DefaultColors.shade_2,
            ),
          Expanded(child: _buildConversationArea()),
        ],
      ),
    );
  }

  Widget _buildConversationArea() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: _isAnalyzing
                  ? null
                  : () => analyzePairwiseConnections(context),
              child: Container(
                decoration: BoxDecoration(
                  color: DefaultColors.type,
                  borderRadius: BorderRadius.circular(20.em),
                ),
                padding: EdgeInsets.all(3.em),
                child: Icon(
                  Icons.psychology,
                  size: 30.em,
                  color: DefaultColors.bg,
                ),
              ),
            ),
            SizedBox(height: 18),
            Text(
              '开始分析',
              style: TextStyle(
                fontSize: 8.em,
                color: DefaultColors.fg,
                fontFamily: "朱雀仿宋",
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _chatScrollController,
      padding: EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (_, index) => _buildChatBubble(_messages[index]),
    );
  }

  Widget _buildChatBubble(_ImagineMessage message) {
    final textColor = message.isUser ? DefaultColors.special : DefaultColors.fg;
    final baseStyle = TextStyle(
      fontSize: 20,
      height: 1.5,
      color: textColor,
      fontFamily: "朱雀仿宋",
    );

    final contentText = message.content.isEmpty
        ? (message.isStreaming ? "…" : " ")
        : message.content;

    Widget body;
    if (message.isUser) {
      body = SelectableText(contentText, style: baseStyle);
    } else {
      body = _StreamingGlowText(
        text: contentText,
        style: baseStyle,
        animate: message.isStreaming,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.title.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                message.title,
                style: TextStyle(
                  fontSize: 18,
                  color: DefaultColors.shade_5,
                  fontFamily: "朱雀仿宋",
                ),
              ),
            ),
          body,
          Divider(
            height: 20,
            thickness: 1,
            color: DefaultColors.shade_3.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  void _attachClue(DateTime key, String clue) {
    final clues = _recordingsClues.putIfAbsent(key, () => []);
    if (!clues.contains(clue)) {
      clues.add(clue);
    }
  }

  void _registerGraphEdge({
    required DateTime from,
    required DateTime to,
    required double score,
    required String clue,
    required String explanation,
  }) {
    final edge = _RecordingEdge(
      from: from,
      to: to,
      score: score,
      clue: clue,
      explanation: explanation,
    );

    _graphEdges.add(edge);
    _graphAdjacency.putIfAbsent(from, () => []).add(edge);
  }

  String _formatMonthDay(DateTime time) =>
      "${time.month.toString().padLeft(2, '0')}/${time.day.toString().padLeft(2, '0')}";

  _ImagineMessage _addMessage({
    required bool isUser,
    String title = '',
    String content = '',
    bool isStreaming = false,
  }) {
    final message = _ImagineMessage(
      id: _nextMessageId(),
      isUser: isUser,
      title: title,
      content: content,
      isStreaming: isStreaming,
    );

    if (!mounted) return message;
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
    return message;
  }

  void _setMessageContent(String id, String content) {
    _editMessage(id, (message) => message.content = content);
  }

  void _appendToMessage(String id, String text) {
    if (text.isEmpty) return;
    _editMessage(id, (message) => message.content += text);
  }

  void _removeMessage(String id) {
    if (!mounted) return;
    setState(() => _messages.removeWhere((msg) => msg.id == id));
  }

  void _setMessageStreaming(String id, bool streaming) {
    _editMessage(id, (message) => message.isStreaming = streaming);
  }

  void _editMessage(String id, void Function(_ImagineMessage message) updater) {
    if (!mounted) return;
    final index = _messages.indexWhere((msg) => msg.id == id);
    if (index == -1) return;
    setState(() {
      updater(_messages[index]);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatScrollController.hasClients) return;
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  String _nextMessageId() => "msg_${_messageCounter++}";

  _ImagineMessage _emitCodexUpdate(String content, {bool streaming = false}) =>
      _addMessage(
        isUser: false,
        title: "系统提示",
        content: content,
        isStreaming: streaming,
      );

  Future<_StreamedDetailResult?> _streamDetailResponse({
    required String messageId,
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final buffer = StringBuffer();
    try {
      await for (final chunk in Llm.streamChat(
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
      )) {
        if (chunk.isEmpty) continue;
        buffer.write(chunk);
        _appendToMessage(messageId, chunk);
      }
    } catch (e) {
      _appendToMessage(messageId, "\n[线索请求出错: $e]");
      return null;
    }

    final responseText = buffer.toString().trim();
    if (responseText.isEmpty) {
      _appendToMessage(messageId, "\n[线索响应为空]");
      return null;
    }

    final clue = _extractDetailField(responseText, 'clue');
    final explanation = _extractDetailField(responseText, 'exp');

    if (clue == null || explanation == null) {
      _appendToMessage(messageId, "\n[线索格式无法解析]");
      return null;
    }

    return _StreamedDetailResult(clue: clue, explanation: explanation);
  }

  String? _extractDetailField(String text, String field) {
    final regex = RegExp(
      '^$field\\s*[:：]\\s*(.+)\$',
      multiLine: true,
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    if (match == null) return null;
    return match.group(1)?.trim();
  }
}

// maybe popup and ask permission for download
Future<bool> maybeDownloadGeoData(BuildContext context) async {
  final l = AppLocalizations.of(context)!;
  final dest = (await getApplicationSupportDirectory()).path;

  if (await ss.read(key: ss.LLM_MODEL_SETTINGS) == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.missing_llm_settings),
          duration: Duration(seconds: 5),
        ),
      );
    }
    return false;
  }

  if (!File(path.join(dest, GEO_DATA)).existsSync() && context.mounted) {
    final perm = await showYesNoDialog(
      context,
      l.imagine_download_geo_desc,
      l.imagine_download_geo_no,
      l.imagine_download_geo_yes,
    );

    if (perm && context.mounted) {
      // download
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => DownloadUnzipDialog(
          urls: ["https://download.geonames.org/export/dump/cities15000.zip"],
          dest: dest,
        ),
      );

      return true;
    }

    return false;
  } else {
    return true;
  }
}

class _GraphNodeInfo {
  final DateTime time;
  final List<String> clues;

  _GraphNodeInfo({required this.time, required this.clues});

  String get shortLabel =>
      "${time.month.toString().padLeft(2, '0')}/${time.day.toString().padLeft(2, '0')}";

  String get snippet {
    if (clues.isEmpty) return '暂无线索';
    final preview = clues.take(2).join(' / ');
    final remaining = clues.length - 2;
    return remaining > 0 ? "$preview +$remaining" : preview;
  }

  String get tooltip => clues.isEmpty ? '暂无线索' : clues.join('\n');
}

class _RecordingEdge {
  final DateTime from;
  final DateTime to;
  final double score;
  final String clue;
  final String explanation;

  const _RecordingEdge({
    required this.from,
    required this.to,
    required this.score,
    required this.clue,
    required this.explanation,
  });

  String describe() {
    final intervalDays = to.difference(from).inDays;
    final buffer = StringBuffer()
      ..write(
        "• ${_fmt(from)} → ${_fmt(to)} | 分数 ${score.toStringAsFixed(2)} | 标签 $clue | $explanation (间隔 $intervalDays 天)\n",
      );
    return buffer.toString();
  }

  String _fmt(DateTime dt) =>
      "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
}

class _ImagineMessage {
  final String id;
  final bool isUser;
  final String title;
  String content;
  bool isStreaming;

  _ImagineMessage({
    required this.id,
    required this.isUser,
    this.title = '',
    this.content = '',
    this.isStreaming = false,
  });
}

class _StreamedDetailResult {
  final String clue;
  final String explanation;

  const _StreamedDetailResult({required this.clue, required this.explanation});
}

class _StreamingGlowText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final bool animate;

  const _StreamingGlowText({
    required this.text,
    required this.style,
    this.animate = false,
  });

  @override
  State<_StreamingGlowText> createState() => _StreamingGlowTextState();
}

class _StreamingGlowTextState extends State<_StreamingGlowText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_StreamingGlowText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return Text(widget.text, style: widget.style);
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            final width = bounds.width == 0 ? 1.0 : bounds.width;
            final travel = width * 1.5;
            final offset = (travel * _controller.value) - (travel / 2);
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.style.color?.withValues(alpha: 0.2) ?? Colors.white24,
                DefaultColors.bg,
                widget.style.color?.withValues(alpha: 0.2) ?? Colors.white24,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(Rect.fromLTWH(offset, 0, width, bounds.height));
          },
          blendMode: BlendMode.srcATop,
          child: Text(widget.text, style: widget.style),
        );
      },
    );
  }
}
