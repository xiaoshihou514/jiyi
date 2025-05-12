import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jiyi/em.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/authenticator.dart';

class HomePage extends StatefulWidget {
  final bool skipEncryption;
  const HomePage(this.skipEncryption, {super.key});

  @override
  // ignore: no_logic_in_create_state
  State<HomePage> createState() => _HomePage(skipEncryption);
}

class _HomePage extends State<HomePage> {
  final storage = FlutterSecureStorage();
  bool unlocked = false;

  _HomePage(this.unlocked);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    if (!unlocked) {
      _maybeUnlock();
    }
    return unlocked
        ? _page
        : Container(
          color: DefaultColors.bg,
          child: IconButton(
            icon: Icon(Icons.lock, size: 40.em, color: DefaultColors.error),
            onPressed: _maybeUnlock,
          ),
        );
  }

  Future<void> _maybeUnlock() async {
    final AuthResult result = await Authenticator.authenticate(
      AppLocalizations.of(context)!.auth_unlock_reason,
    );
    switch (result) {
      case AuthResult.success:
        setState(() => unlocked = true);
      case AuthResult.error:
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.auth_unlock_err),
              duration: Durations.long1,
            ),
          );
        }
      case AuthResult.failure:
        break;
    }
  }

  Widget get _page {
    return const Scaffold();
  }
}
