import 'package:flutter/material.dart';
import 'package:jiyi/utils/io.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 5), () => print(IO.index));
    return Placeholder();
  }
}
