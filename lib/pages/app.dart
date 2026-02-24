import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jiyi/pages/home.dart';
import 'package:jiyi/pages/record.dart';
import 'package:jiyi/pages/setup/welcome.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/utils/app_lifecycle_overlay.dart';
import 'package:jiyi/utils/smooth_router.dart';

class App extends StatefulWidget {
  final String? masterKey;
  final String? storagePath;
  const App(this.masterKey, this.storagePath, {super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  static const platform = MethodChannel('com.github.xiaoshihou.jiyi/widget');
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _setupMethodChannel();
  }

  void _setupMethodChannel() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'startRecording') {
        // Only navigate if storage is configured
        if (widget.masterKey != null && widget.storagePath != null) {
          navigatorKey.currentState?.push(
            SmoothRouter.builder(RecordPage(widget.storagePath!)),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: (widget.masterKey == null || widget.storagePath == null)
          ? WelcomePage(widget.masterKey, widget.storagePath)
          : AppLifecycleOverlay(
              child: HomePage(false, widget.storagePath!, widget.masterKey!),
            ),
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
