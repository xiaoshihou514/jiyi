import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:pointycastle/key_derivators/argon2.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/stream/chacha20poly1305.dart';

class Encryption {
  // ignore: constant_identifier_names
  static const ENC_KEY_LEN = ChaCha20Poly1305.KEY_SIZE;
  static bool _init = false;
  static final _srand = SecureRandom('Fortuna') as FortunaRandom;
  static late final Encryption _instance;

  final Uint8List encryptionKey;
  final Uint8List nouce;

  Encryption({required this.encryptionKey, required this.nouce});

  static Encryption get instance => _instance;

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

    // init srand
    final r = Random();
    final seed = Uint8List.fromList(
      List.generate(32, (i) => r.nextInt(1 << 10)),
    );
    _srand.seed(KeyParameter(seed));

    final nonce = _srand.nextBytes(ChaCha20Poly1305.NONCE_SIZE);

    _instance = Encryption(encryptionKey: buf, nouce: nonce);
    _init = true;
  }

  // for compute which runs in another process
  static void initByInstance(Encryption enc) {
    if (_init) {
      return;
    }
    _instance = enc;
    _init = true;
  }

  static Future<Uint8List> encrypt(Uint8List data) async {
    assert(_init);
    return Encryption.instance._encrypt(data);
  }

  Future<Uint8List> _encrypt(Uint8List data) async {
    final encEngine = AEADCipher("ChaCha20-Poly1305");
    encEngine.init(
      true,
      ParametersWithIV<KeyParameter>(KeyParameter(encryptionKey), nouce),
    );

    // input len + tag len
    final out = Uint8List(data.length + encEngine.mac.length);

    // encrypt
    final processedLen = encEngine.processBytes(data, 0, data.length, out, 0);

    // append tag
    final totalLen = processedLen + encEngine.doFinal(out, processedLen);

    // encrypted + tag + nouce
    final result = BytesBuilder()
      ..add(out.sublist(0, totalLen))
      ..add(nouce);

    return result.toBytes();
  }

  static Future<Uint8List> decrypt(Uint8List data) async {
    assert(_init);
    return instance._decrypt(data);
  }

  Future<Uint8List> _decrypt(Uint8List data) async {
    final nonceSize = ChaCha20Poly1305.NONCE_SIZE;
    final nonce = data.sublist(data.length - nonceSize);
    final ciphertextWithTag = data.sublist(0, data.length - nonceSize);

    final decEngine = AEADCipher("ChaCha20-Poly1305");
    decEngine.init(
      false,
      ParametersWithIV<KeyParameter>(KeyParameter(encryptionKey), nonce),
    );

    final out = Uint8List(ciphertextWithTag.length - decEngine.mac.length);

    // decrypt
    final len = decEngine.processBytes(
      ciphertextWithTag,
      0,
      ciphertextWithTag.length,
      out,
      0,
    );

    return out.sublist(0, len);
  }
}
