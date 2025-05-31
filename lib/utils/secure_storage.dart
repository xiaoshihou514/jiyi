import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ignore: non_constant_identifier_names
final String MASTER_KEY_KEY = "JIYI_MASTER_KEY";
// ignore: non_constant_identifier_names
final String STORAGE_PATH_KEY = "JIYI_STORAGE";
final storage = FlutterSecureStorage();

Future<String?> read({required String key}) => storage.read(key: key);

Future<void> delete({required String key}) => storage.delete(key: key);

Future<void> write({required String key, required String? value}) =>
    storage.write(key: key, value: value);
