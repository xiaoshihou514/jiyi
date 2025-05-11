import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

class WelcomePage extends StatelessWidget {
  final String? masterKey;
  final String? storagePath;
  const WelcomePage(this.masterKey, this.storagePath, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text(AppLocalizations.of(context)!.desc));
  }
}
