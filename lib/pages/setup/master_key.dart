import 'package:flutter/material.dart';

import 'package:jiyi/pages/default_colors.dart';

const durationDim = Duration(seconds: 2);

class MasterKeyPage extends StatelessWidget {
  const MasterKeyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DefaultColors.bg,
      child: Column(children: [Text("foo")]),
    );
  }
}
