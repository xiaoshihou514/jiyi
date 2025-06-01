import 'package:flutter/material.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;

import 'pages/app.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print(await ss.read(key: ss.MASTER_KEY));
  print(await ss.read(key: ss.STORAGE_PATH));

  final String? masterKey = await ss.read(key: ss.MASTER_KEY);
  final String? storagePath = await ss.read(key: ss.STORAGE_PATH);

  runApp(App(masterKey, storagePath));
}
