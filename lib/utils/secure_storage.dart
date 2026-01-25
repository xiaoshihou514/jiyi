import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ignore_for_file: non_constant_identifier_names
final String MASTER_KEY = "JIYI_MASTER_KEY";
final String STORAGE_PATH = "JIYI_STORAGE";
final String MAP_SETTINGS = "JIYI_MAP_SETTINGS";
// JIYI_TTS_SETTINGS in 1.0.0, JIYI_ASR_SETTINGS since 1.0.1
final String ASR_MODEL_SETTINGS = "JIYI_ASR_SETTINGS";
final String ZDPP_MODEL_SETTINGS = "JIYI_ZDPP_SETTINGS";

final storage = FlutterSecureStorage();

Future<String?> read({required String key}) => storage.read(key: key);

Future<void> delete({required String key}) => storage.delete(key: key);

Future<void> write({required String key, required String? value}) =>
    storage.write(key: key, value: value);
