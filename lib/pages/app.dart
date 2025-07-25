import 'package:flutter/material.dart';

import 'package:jiyi/pages/home.dart';
import 'package:jiyi/pages/setup/welcome.dart';
import 'package:jiyi/l10n/localizations.dart';

class App extends StatelessWidget {
  final String? masterKey;
  final String? storagePath;
  const App(this.masterKey, this.storagePath, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: (masterKey == null || storagePath == null)
          ? WelcomePage(masterKey, storagePath)
          : HomePage(false, storagePath!, masterKey!),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}
