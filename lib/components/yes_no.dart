import 'package:flutter/material.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/em.dart';

class YesNo extends StatefulWidget {
  final String message;
  final String negativeText;
  final String positiveText;

  const YesNo({
    super.key,
    required this.message,
    required this.negativeText,
    required this.positiveText,
  });

  @override
  State<YesNo> createState() => _YesNoState();
}

class _YesNoState extends State<YesNo> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DefaultColors.bg,
      content: ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: 120.em),
        child: Text(
          widget.message,
          style: TextStyle(
            fontSize: 7.em,
            decoration: TextDecoration.none,
            color: DefaultColors.fg,
            fontFamily: "朱雀仿宋",
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            widget.negativeText,
            style: TextStyle(
              decoration: TextDecoration.none,
              color: DefaultColors.fg,
              fontFamily: "朱雀仿宋",
              fontSize: 5.em,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            widget.positiveText,
            style: TextStyle(
              decoration: TextDecoration.none,
              color: DefaultColors.fg,
              fontFamily: "朱雀仿宋",
              fontSize: 5.em,
            ),
          ),
        ),
      ],
    );
  }
}

Future<bool> showYesNoDialog(
  BuildContext context,
  String message,
  String negative,
  String positive,
) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        YesNo(message: message, negativeText: negative, positiveText: positive),
  );
}
