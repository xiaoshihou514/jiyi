import 'package:flutter/material.dart';

import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/em.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.settings, size: 50.em, color: DefaultColors.special);
  }
}
