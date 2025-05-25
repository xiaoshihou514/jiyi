import 'package:flutter/material.dart';

import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/em.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.calendar_month,
      size: 50.em,
      color: DefaultColors.special,
    );
  }
}
