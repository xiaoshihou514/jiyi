import 'dart:io';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

enum AuthResult { success, failure, error }

abstract class Authenticator {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<AuthResult> authenticate(String reason) async {
    return await (Platform.isLinux ? _authLinux(reason) : _authOther(reason));
  }

  static Future<AuthResult> _authLinux(String reason) async {
    return AuthResult.failure;
  }

  static Future<AuthResult> _authOther(String reason) async {
    final bool canAuthenticateWithBiometrics =
        await _auth.canCheckBiometrics &&
        (await _auth.getAvailableBiometrics()).isNotEmpty;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    if (!canAuthenticate) {
      return AuthResult.error;
    }

    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
      );
      return didAuthenticate ? AuthResult.success : AuthResult.failure;
    } on PlatformException {
      return AuthResult.error;
    }
  }
}
