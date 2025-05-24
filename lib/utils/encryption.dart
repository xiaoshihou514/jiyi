import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import "package:pointycastle/pointycastle.dart";
import 'package:pointycastle/stream/chacha20poly1305.dart';

abstract class Encryption {
  static bool _init = false;
  static late Uint8List _encryptionKey;
  static late AEADCipher _encEngine;
  static late AEADCipher _decEngine;
  // ignore: constant_identifier_names
  static const ENC_KEY_LEN = ChaCha20Poly1305.KEY_SIZE;

  static Future<Uint8List> _readSaltOrCreate(String storagePath) async {
    final fd = File(path.join(storagePath, "salt.txt"));
    if (fd.existsSync()) {
      return await fd.readAsBytes();
    } else {
      final saltBytes = [DateTime.now().toLocal().hashCode];
      final salt = Uint8List.fromList(saltBytes);
      fd.writeAsBytesSync(saltBytes);
      return salt;
    }
  }

  static Future<void> init(String masterKey, String storagePath) async {
    final d = KeyDerivator('scrypt/argon2');
    final Uint8List salt = await _readSaltOrCreate(storagePath);
    d.init(
      Argon2Parameters(
        Argon2Parameters.DEFAULT_TYPE,
        salt,
        desiredKeyLength: ENC_KEY_LEN,
      ),
    );
    final buf = Uint8List(ENC_KEY_LEN);
    d.deriveKey(Uint8List.fromList(masterKey.runes.toList()), 0, buf, 0);
    _encryptionKey = buf;

    _init = true;
  }

  static Future<Uint8List> encrypt(Uint8List data) async {
    assert(_init);

    final nouce = SecureRandom().nextBytes(ChaCha20Poly1305.NONCE_SIZE);
    _encEngine = AEADCipher("ChaCha20-Poly1305");
    _encEngine.init(
      true,
      ParametersWithIV<KeyParameter>(KeyParameter(_encryptionKey), nouce),
    );

    final len = _encEngine.doFinal(data, 0);
    final buf = Uint8List(len + ChaCha20Poly1305.NONCE_SIZE);
    buf.replaceRange(0, len, data);
    buf.replaceRange(len, len + ChaCha20Poly1305.NONCE_SIZE, nouce);
    return buf;
  }

  static Future<Uint8List> decrypt(Uint8List data) async {
    final nouceStart = data.length - ChaCha20Poly1305.NONCE_SIZE;
    final nouce = data.sublist(nouceStart);
    final encrypted = data.sublist(0, nouceStart);

    _decEngine = AEADCipher("ChaCha20-Poly1305");
    _decEngine.init(
      false,
      ParametersWithIV<KeyParameter>(KeyParameter(_encryptionKey), nouce),
    );

    final len = _decEngine.doFinal(encrypted, 0);
    return encrypted.sublist(0, len);
  }
}
