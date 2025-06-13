import 'package:flutter/material.dart';

class Player extends StatefulWidget {
  final DateTime _date;
  const Player(this._date, {super.key});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
