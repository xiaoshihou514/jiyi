import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jiyi/utils/notifier.dart';
import 'package:provider/provider.dart';

import 'pages/app.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  final String? masterKey = await ss.read(key: ss.MASTER_KEY);
  final String? storagePath = await ss.read(key: ss.STORAGE_PATH);

  runApp(
    ChangeNotifierProvider.value(
      value: Notifier(),
      child: App(masterKey, storagePath),
    ),
  );
}
