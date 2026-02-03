import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:jiyi/utils/anno.dart';
import 'package:path/path.dart' as path;
import 'package:pointycastle/key_derivators/argon2.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/stream/chacha20poly1305.dart';

class Encryption {
  // ignore: constant_identifier_names
  static const ENC_KEY_LEN = ChaCha20Poly1305.KEY_SIZE;
  static bool _init = false;
  static late final Encryption _instance;

  final Uint8List encryptionKey;
  late final FortunaRandom rand;

  Encryption({required this.encryptionKey});

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

    _instance = Encryption(encryptionKey: buf);
    _instance.rand = SecureRandom('Fortuna') as FortunaRandom;
    _instance.rand.seed(KeyParameter(seed));
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

  @DeepSeek()
  Future<Uint8List> _encrypt(Uint8List data) async {
    final encEngine = AEADCipher("ChaCha20-Poly1305");
    final nonce = rand.nextBytes(ChaCha20Poly1305.NONCE_SIZE);
    encEngine.init(
      true,
      ParametersWithIV<KeyParameter>(KeyParameter(encryptionKey), nonce),
    );

    // input len + tag len
    final out = Uint8List(data.length + encEngine.mac.length);

    // encrypt
    int processedLen = encEngine.processBytes(data, 0, data.length, out, 0);

    processedLen += encEngine.doFinal(out, processedLen);

    return Uint8List.fromList([...out.sublist(0, processedLen), ...nonce]);
  }

  static Future<Uint8List> decrypt(Uint8List data) async {
    assert(_init);
    return instance._decrypt(data);
  }

  @Grok()
  Future<Uint8List> _decrypt(Uint8List data) async {
    // Extract nonce (last 12 bytes)
    final nonceSize = ChaCha20Poly1305.NONCE_SIZE; // 12 bytes
    final nonce = data.sublist(data.length - nonceSize);

    // Extract ciphertext + tag (everything except the nonce)
    final ciphertextWithTag = data.sublist(0, data.length - nonceSize);

    // Initialize decryption engine
    final decEngine = AEADCipher("ChaCha20-Poly1305");
    decEngine.init(
      false, // Decryption mode
      ParametersWithIV<KeyParameter>(KeyParameter(encryptionKey), nonce),
    );

    // Output buffer size: ciphertext length minus tag size (16 bytes)
    final out = Uint8List(ciphertextWithTag.length - decEngine.mac.length);

    // Process the entire ciphertext + tag
    final len = decEngine.processBytes(
      ciphertextWithTag,
      0,
      ciphertextWithTag.length,
      out,
      0,
    );

    // Finalize decryption and verify tag
    final finalLen = len + decEngine.doFinal(out, len);

    // Return the decrypted data
    return out.sublist(0, finalLen);
  }
}
