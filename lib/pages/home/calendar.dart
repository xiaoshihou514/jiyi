import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:jiyi/components/spinner.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/pages/player.dart';
import 'package:jiyi/pages/playlist.dart';
import 'package:jiyi/utils/anno.dart';
import 'package:jiyi/utils/em.dart';
import 'package:jiyi/utils/io.dart';
import 'package:jiyi/utils/metadata.dart';
import 'package:jiyi/utils/notifier.dart';
import 'package:jiyi/utils/smooth_router.dart';
import 'package:jiyi/utils/text_color.dart';

@DeepSeek()
class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final Map<DateTime, List<String>> _dailyCovers = {};
  final Map<String, List<DateTime>> _entriesByMonth = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<Notifier>(
      builder: (context, counter, child) => FutureBuilder<List<Metadata>>(
        future: IO.indexFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Spinner(Icons.sync, DefaultColors.keyword, 30.em),
            );
          }

          final records = snapshot.data ?? [];
          _processRecords(records);

          return Container(
            color: DefaultColors.bg,
            padding: EdgeInsets.symmetric(horizontal: 6.em, vertical: 3.em),
            child: ListView(children: _buildMonthSections(context)),
          );
        },
      ),
    );
  }

  void _processRecords(List<Metadata> records) {
    _dailyCovers.clear();
    _entriesByMonth.clear();

    // 按日期分组状态封面
    for (final record in records) {
      final date = DateTime(
        record.time.year,
        record.time.month,
        record.time.day,
      );

      _dailyCovers.putIfAbsent(date, () => []).add(record.cover);
    }

    // 按月份组织日期
    final dates = _dailyCovers.keys.toList()..sort((a, b) => b.compareTo(a));
    for (final date in dates) {
      final monthKey = '${date.year}-${date.month}';
      _entriesByMonth.putIfAbsent(monthKey, () => []).add(date);
    }
  }

  List<Widget> _buildMonthSections(BuildContext context) =>
      (_entriesByMonth.keys.toList()..sort((a, b) => b.compareTo(a))).map((
        monthKey,
      ) {
        final dates = _entriesByMonth[monthKey]!;
        final firstDate = dates.first;
        final monthTitle = '${firstDate.year}.${firstDate.month}';

        return Container(
          margin: EdgeInsets.only(bottom: 9.em),
          decoration: BoxDecoration(
            color: DefaultColors.shade_1,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(5.em),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 30.em,
                  child: Text(
                    monthTitle,
                    style: TextStyle(
                      color: DefaultColors.fg,
                      fontSize: 7.5.em,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Wrap(
                    spacing: 4.5.em,
                    runSpacing: 4.5.em,
                    children: dates
                        .map(
                          (date) => _buildDateStatus(_dailyCovers[date]!, date),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList();

  Widget _buildDateStatus(List<String> covers, DateTime date) {
    final shown = covers.sublist(0, min(covers.length, 2));
    final size = 15.em;
    final offset = 3.5.em; // 重叠偏移量
    final circleCount = shown.length;
    return Column(
      children: [
        IconButton(
          onPressed: () {
            if (context.mounted) {
              Navigator.push(
                context,
                SmoothRouter.builder(
                  covers.length == 1
                      ? Player(IO.metadataByDay(date).first)
                      : Playlist(IO.metadataByDay(date)),
                ),
              );
            }
          },
          icon: SizedBox(
            width: size + offset * (circleCount - 1),
            height: size,
            child: Stack(
              children: List.generate(circleCount, (index) {
                return Positioned(
                  right: offset * index,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: getStatusColor(shown[index]),
                      shape: BoxShape.circle,
                      border: Border.all(color: DefaultColors.bg, width: 1.em),
                    ),
                    child: Center(
                      child: Text(
                        shown[index],
                        style: TextStyle(fontSize: 7.5.em),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        SizedBox(height: 2.em),
        Text(
          date.day.toString(),
          style: TextStyle(fontSize: 5.em, color: DefaultColors.fg),
        ),
      ],
    );
  }
}
