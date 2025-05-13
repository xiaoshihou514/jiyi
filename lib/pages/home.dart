import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jiyi/em.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/authenticator.dart';
import 'package:jiyi/pages/record.dart';
import 'package:jiyi/smooth_router.dart';

class HomePage extends StatefulWidget {
  final bool skipEncryption;
  const HomePage(this.skipEncryption, {super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final storage = FlutterSecureStorage();
  bool unlocked = false;

  _HomePage();

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    unlocked |= widget.skipEncryption;

    // authorize
    if (!unlocked) {
      _maybeUnlock();
    }
    return unlocked
        ? _page
        : Scaffold(
          backgroundColor: DefaultColors.bg,
          body: Center(
            child: Container(
              color: DefaultColors.bg,
              child: IconButton(
                icon: Icon(Icons.lock, size: 40.em, color: DefaultColors.error),
                onPressed: _maybeUnlock,
                hoverColor: Colors.transparent,
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                ),
              ),
            ),
          ),
        );
  }

  Future<void> _maybeUnlock() async {
    final AuthResult result = await Authenticator.authenticate(
      context,
      AppLocalizations.of(context)!.auth_unlock_reason,
    );
    switch (result) {
      case AuthResult.success:
        // successfully authorized
        setState(() => unlocked = true);
      case AuthResult.error:
        // display error in snack bar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.auth_unlock_err),
              duration: Durations.long1,
            ),
          );
        }
      case AuthResult.failure:
        // silently fail
        break;
    }
  }

  Widget get _page {
    bool isMobile = ScreenUtil().screenWidth <= ScreenUtil().screenHeight;
    return Scaffold(
      backgroundColor: DefaultColors.bg,
      floatingActionButton: IconButton(
        onPressed:
            () => {Navigator.push(context, SmoothRouter.builder(RecordPage()))},
        icon: Container(
          width: isMobile ? 25.em : 10.em,
          height: isMobile ? 25.em : 10.em,
          decoration: BoxDecoration(
            color: DefaultColors.special,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.mic,
            color: DefaultColors.bg,
            size: isMobile ? 20.em : 7.5.em,
          ),
        ),
      ),
    );
  }
}
