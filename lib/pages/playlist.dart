import 'package:flutter/material.dart';
import 'package:jiyi/utils/anno.dart';
import 'package:jiyi/utils/io.dart';

@DeepSeek()
class Playlist extends StatefulWidget {
  final DateTime _day;
  const Playlist(this._day, {super.key});

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  @override
  Widget build(BuildContext context) {
    print(IO.entriesByDay(widget._day));
    // [File: '/home/xiaoshihou/Playground/scratch/jiyi_storage_test/482133658', File: '/home/xiaoshihou/Playground/scratch/jiyi_storage_test/564972836']
    return const Placeholder();
  }
}
