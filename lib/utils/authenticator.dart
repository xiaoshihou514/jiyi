import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:local_auth/local_auth.dart";

import "package:jiyi/utils/em.dart";
import "package:jiyi/l10n/localizations.dart";
import "package:jiyi/pages/default_colors.dart";

enum AuthResult { success, failure, error }

class PasswordDialog extends StatefulWidget {
  final String username;
  final File? avatar;

  const PasswordDialog({required this.username, this.avatar, super.key});

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  bool _showPassword = false;
  bool _enteredIncorrectPass = false;
  late FocusNode _inputFocus;

  @override
  void initState() {
    super.initState();
    _inputFocus = FocusNode();
  }

  @override
  void dispose() {
    _inputFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final bool didAuthenticate = await Authenticator._authenticate(
      _controller.text,
    );
    if (didAuthenticate) {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      setState(() => _enteredIncorrectPass = true);
      _inputFocus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: DefaultColors.shade_2,

      child: DefaultTextStyle.merge(
        style: TextStyle(
          decoration: TextDecoration.none,
          color: DefaultColors.fg,
          fontFamily: "朱雀仿宋",
        ),
        child: Stack(
          fit: StackFit.loose,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(8.em, 8.em, 8.em, 10.em),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8.em,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 2.em,
                    children: [
                      Text(widget.username, style: TextStyle(fontSize: 4.em)),
                      widget.avatar != null
                          ? CircleAvatar(
                              backgroundImage: FileImage(widget.avatar!),
                              radius: 10.em,
                            )
                          : Icon(size: 10.em, Icons.account_circle),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 3.em,
                    children: [
                      Text(
                        l.auth_unlock_reason,
                        style: TextStyle(
                          fontSize: 5.em,
                          color: DefaultColors.keyword,
                        ),
                      ),
                      SizedBox(
                        height: 10.em,
                        width: 50.em,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            textSelectionTheme: TextSelectionThemeData(
                              selectionColor: DefaultColors.shade_3,
                              selectionHandleColor: DefaultColors.shade_4,
                            ),
                          ),
                          child: TextField(
                            controller: _controller,
                            obscureText: !_showPassword,
                            autofocus: true,
                            focusNode: _inputFocus,
                            cursorColor: DefaultColors.shade_6,
                            onSubmitted: (content) => _submit(),
                            decoration: InputDecoration(
                              // toggle obscureText
                              suffixIcon: IconButton(
                                color: DefaultColors.info,
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(
                                  () => _showPassword = !_showPassword,
                                ),
                              ),
                              fillColor: DefaultColors.bg,
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: _enteredIncorrectPass
                                      ? DefaultColors.error
                                      : Colors.transparent,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: _enteredIncorrectPass
                                      ? DefaultColors.error
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                            style: TextStyle(
                              color: DefaultColors.fg,
                              fontSize: 4.em,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 3.em,
              right: 3.em,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => {
                      if (mounted) {Navigator.of(context).pop(false)},
                    },
                    child: Text(
                      l.auth_linux_cancel,
                      style: TextStyle(
                        fontSize: 4.em,
                        decoration: TextDecoration.none,
                        color: DefaultColors.constant,
                        fontFamily: "朱雀仿宋",
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _submit,
                    child: Text(
                      l.auth_linux_enter,
                      style: TextStyle(
                        fontSize: 4.em,
                        decoration: TextDecoration.none,
                        color: DefaultColors.constant,
                        fontFamily: "朱雀仿宋",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

abstract class Authenticator {
  static final LocalAuthentication _auth = LocalAuthentication();
  static final MethodChannel _methodChannel = const MethodChannel(
    "com.github.xiaoshihou.ffi",
  );

  static Future<AuthResult> authenticate(
    BuildContext context,
    String reason,
  ) async {
    return await (Platform.isLinux
        ? _authLinux(context, reason)
        : _authOther(reason));
  }

  static Future<String?> _getRealName() async =>
      await _methodChannel.invokeMethod<String>("localAuth.getRealName");
  static Future<String?> _getAvatarPath() async =>
      await _methodChannel.invokeMethod<String>("localAuth.getAvatarPath");
  static Future<bool> _authenticate(String password) async =>
      await _methodChannel.invokeMethod<bool>("localAuth.authenticate", {
        "password": password,
      }) ??
      false;

  static Future<bool> _passwordPopup(
    BuildContext context,
    String username,
    File? avatar,
  ) async {
    return (await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              PasswordDialog(username: username, avatar: avatar),
        )) ??
        false;
  }

  static Future<AuthResult> _authLinux(
    BuildContext context,
    String reason,
  ) async {
    String? username = await _getRealName();
    String? avatarPath = await _getAvatarPath();
    File? avatar = avatarPath == null ? null : File(avatarPath);
    if (avatar != null && !avatar.existsSync()) {
      avatar = null;
    }

    if (context.mounted) {
      final bool didAuthenticate = await _passwordPopup(
        context,
        username ?? AppLocalizations.of(context)!.auth_linux_unknown_user,
        avatar,
      );
      return didAuthenticate ? AuthResult.success : AuthResult.failure;
    } else {
      return AuthResult.error;
    }
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
