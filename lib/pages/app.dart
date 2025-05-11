import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
      home:
          (masterKey == null || storagePath == null)
              ? WelcomePage(masterKey, storagePath)
              : HomePage(),

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('zh')],
      debugShowCheckedModeBanner: false,
    );
  }
}
