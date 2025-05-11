import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

import 'package:jiyi/pages/home.dart';
import 'package:jiyi/pages/setup/welcome.dart';

class App extends StatelessWidget {
  final String? masterKey;
  final String? storagePath;
  const App(this.masterKey, this.storagePath, {super.key});

  @override
  Widget build(BuildContext context) {
    Widget? home;
    if (masterKey == null || storagePath == null) {
      home = WelcomePage(masterKey, storagePath);
    } else {
      home = HomePage();
    }
    return MaterialApp(
      home: home,
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
