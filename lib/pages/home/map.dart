import 'package:flutter/material.dart';

import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/em.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.map, size: 50.em, color: DefaultColors.special);
  }
}
