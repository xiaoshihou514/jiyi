import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;

import 'package:jiyi/utils/encryption.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;
import 'package:jiyi/utils/metadata.dart';

abstract class IO {
  // ignore: non_constant_identifier_names
  static late final String STORAGE;
  static late List<Metadata> index;
  static late final File indexFile;
  static bool _init = false;

  static Future<void> init() async {
    if (_init) {
      return;
    }
    STORAGE = (await ss.read(key: ss.STORAGE_PATH))!;
    indexFile = File(path.join(STORAGE, "index"));
    if (indexFile.existsSync()) {
      index = await indexFile
          .readAsBytes()
          .then(Encryption.decrypt)
          .then(utf8.decode)
          .then(jsonDecode)
          .then(
            (data) => (data as List<dynamic>)
                .cast<Map<String, dynamic>>()
                .map(Metadata.fromDyn)
                .toList(),
          );
    } else {
      await rebuild();
    }
    _init = true;
  }

  static Future<void> rebuild() async {
    final result = <Metadata>[];
    if (indexFile.existsSync()) {
      indexFile.deleteSync();
    }

    for (final entry in Directory(STORAGE).listSync()) {
      if (!entry.path.endsWith("bq")) continue;

      final md = await File(entry.path)
          .readAsBytes()
          .then(Encryption.decrypt)
          .then(utf8.decode)
          .then(jsonDecode)
          .then((data) => Metadata.fromDyn(data as Map<String, dynamic>));
      result.add(md);
    }
    index = result;
    await updateIndexOnDisk();
  }

  static Future<void> updateIndexOnDisk() async {
    await indexFile.writeAsBytes(
      await Encryption.encrypt(
        utf8.encode(jsonEncode(index.map((m) => m.dyn).toList())),
      ),
      mode: FileMode.write,
      flush: true,
    );
  }

  static Future<void> save(Uint8List decrypted, Metadata md) async {
    await File(
      path.join(STORAGE, "${md.time.hashCode}.cd"),
    ).writeAsBytes(await Encryption.encrypt(decrypted));
    await File(
      path.join(STORAGE, "${md.time.hashCode}.bq"),
    ).writeAsBytes(await Encryption.encrypt(utf8.encode(md.json)), flush: true);
  }

  static void addEntry(Metadata md) => index.add(md);
}
