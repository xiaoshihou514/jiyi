import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'pages/app.dart';

// ignore: non_constant_identifier_names
final String MASTER_KEY_STORAGE_KEY = "JIYI_MASTER_KEY";
// ignore: non_constant_identifier_names
final String STORAGE_PATH_KEY = "JIYI_STORAGE";

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check settings
  final storage = FlutterSecureStorage();
  final String? masterKey = await storage.read(key: MASTER_KEY_STORAGE_KEY);
  final String? storagePath = await storage.read(key: STORAGE_PATH_KEY);

  runApp(App(masterKey, storagePath));
}
