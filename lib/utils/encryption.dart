import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:pointycastle/key_derivators/argon2.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/stream/chacha20poly1305.dart';

abstract class Encryption {
  static bool _init = false;
  static late Uint8List _encryptionKey;
  static late AEADCipher _encEngine;
  static late AEADCipher _decEngine;
  // ignore: constant_identifier_names
  static const ENC_KEY_LEN = ChaCha20Poly1305.KEY_SIZE;
  static final _srand = SecureRandom('Fortuna') as FortunaRandom;

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
    if (_init) {
      return;
    }

    // calculate encryption key from master key
    final d = Argon2BytesGenerator();
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

    // init srand
    final r = Random();
    final seed = Uint8List.fromList(
      List.generate(32, (i) => r.nextInt(1 << 10)),
    );
    _srand.seed(KeyParameter(seed));

    _init = true;
  }

  static Future<Uint8List> encrypt(Uint8List data) async {
    assert(_init);

    final nonce = _srand.nextBytes(ChaCha20Poly1305.NONCE_SIZE);
    _encEngine = AEADCipher("ChaCha20-Poly1305");
    _encEngine.init(
      true,
      ParametersWithIV<KeyParameter>(KeyParameter(_encryptionKey), nonce),
    );

    // input len + tag len
    final out = Uint8List(data.length + _encEngine.mac.length);

    // encrypt
    final processedLen = _encEngine.processBytes(data, 0, data.length, out, 0);

    // append tag
    final totalLen = processedLen + _encEngine.doFinal(out, processedLen);

    // encrypted + tag + nouce
    final result =
        BytesBuilder()
          ..add(out.sublist(0, totalLen))
          ..add(nonce);

    return result.toBytes();
  }

  static Future<Uint8List> decrypt(Uint8List data) async {
    assert(_init);

    final nonceSize = ChaCha20Poly1305.NONCE_SIZE;
    final nonce = data.sublist(data.length - nonceSize);
    final ciphertextWithTag = data.sublist(0, data.length - nonceSize);

    _decEngine = AEADCipher("ChaCha20-Poly1305");
    _decEngine.init(
      false,
      ParametersWithIV<KeyParameter>(KeyParameter(_encryptionKey), nonce),
    );

    final out = Uint8List(ciphertextWithTag.length - _decEngine.mac.length);

    // decrypt
    final len = _decEngine.processBytes(
      ciphertextWithTag,
      0,
      ciphertextWithTag.length,
      out,
      0,
    );

    return out.sublist(0, len);
  }
}
