import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:jiyi/utils/anno.dart';
import 'package:path/path.dart' as path;

import 'package:jiyi/utils/encryption.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;
import 'package:jiyi/utils/metadata.dart';

abstract class IO {
  // ignore: non_constant_identifier_names
  static late final String STORAGE;
  static late List<Metadata> _index;
  static late final File indexFile;
  static bool _init = false;

  @DeepSeek()
  static Completer<List<Metadata>> completer = Completer();
  static Future<List<Metadata>> indexFuture = completer.future;

  static Future<void> init() async {
    if (_init) {
      return;
    }
    STORAGE = (await ss.read(key: ss.STORAGE_PATH))!;
    indexFile = File(path.join(STORAGE, "index"));
    if (indexFile.existsSync()) {
      completer.complete(
        indexFile
            .readAsBytes()
            .then(Encryption.decrypt)
            .then(utf8.decode)
            .then(jsonDecode)
            .then(
              (data) => (data as List<dynamic>)
                  .cast<Map<String, dynamic>>()
                  .map(Metadata.fromDyn)
                  .toList(),
            ),
      );
      _index = await indexFuture;
    } else {
      await rebuild();
    }
    _init = true;
  }

  static Future<void> rebuild() async {
    final result = <Metadata>[];
    completer = Completer();
    indexFuture = completer.future;

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
    _index = result;

    completer.complete(result);
    _index = result;
    await updateIndexOnDisk();
  }

  static Future<void> updateIndexOnDisk() async {
    await indexFile.writeAsBytes(
      await Encryption.encrypt(
        utf8.encode(jsonEncode(_index.map((m) => m.dyn).toList())),
      ),
      mode: FileMode.write,
      flush: true,
    );
  }

  static Future<void> save(Uint8List decrypted, Metadata md) async {
    final fname = (md.time.toString() + DateTime.now().toString()).hashCode;
    await File(
      path.join(STORAGE, "$fname.cd"),
    ).writeAsBytes(await Encryption.encrypt(decrypted));
    await File(
      path.join(STORAGE, "$fname.bq"),
    ).writeAsBytes(await Encryption.encrypt(utf8.encode(md.json)), flush: true);
  }

  static void addEntry(Metadata md) => _index.add(md);
}
