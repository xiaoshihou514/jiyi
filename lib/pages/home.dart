import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiyi/components/md_input.dart';

import 'package:jiyi/pages/home/calendar.dart';
import 'package:jiyi/pages/home/map.dart';
import 'package:jiyi/pages/home/settings.dart';
import 'package:jiyi/pages/search.dart';
import 'package:jiyi/utils/em.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/authenticator.dart';
import 'package:jiyi/pages/record.dart';
import 'package:jiyi/utils/encryption.dart';
import 'package:jiyi/utils/io.dart';
import 'package:jiyi/utils/notifier.dart';
import 'package:jiyi/utils/smooth_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final bool skipEncryption;
  final String storagePath;
  final String masterKey;
  const HomePage(
    this.skipEncryption,
    this.storagePath,
    this.masterKey, {
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> with SingleTickerProviderStateMixin {
  bool unlocked = false;
  late TabController _tabController;

  _HomePage();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _setupEncryption();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

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
                  icon: Icon(
                    Icons.lock,
                    size: 40.em,
                    color: DefaultColors.error,
                  ),
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
    late final AuthResult result;
    if (kDebugMode) {
      result = AuthResult.success;
      debugPrint("skipping auth...");
    } else {
      result = await Authenticator.authenticate(
        context,
        AppLocalizations.of(context)!.auth_unlock_reason,
      );
    }
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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: DefaultColors.bg,
        body: TabBarView(
          controller: _tabController,
          children: [
            Calendar(),
            MapView(AppLocalizations.of(context)!),
            Settings(),
          ],
        ),
        appBar: AppBar(
          backgroundColor: DefaultColors.bg,
          toolbarHeight: 3.em,
          bottom: TabBar(
            controller: _tabController,
            labelColor: DefaultColors.keyword,
            indicatorColor: DefaultColors.keyword,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                icon: Icon(Icons.calendar_month, size: isMobile ? 15.em : 5.em),
              ),
              Tab(icon: Icon(Icons.map, size: isMobile ? 15.em : 5.em)),
              Tab(icon: Icon(Icons.settings, size: isMobile ? 15.em : 5.em)),
            ],
          ),
        ),
        floatingActionButton:
            _tabController.index == 0 ? _floatingBtns(isMobile) : null,
      ),
    );
  }

  Widget _floatingBtns(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _floatingBtn(isMobile, DefaultColors.func, Icons.upload, () async {
          await showMetadataInputDialog(context);
          if (mounted) {
            context.read<Notifier>().trigger();
          }
        }),
        _floatingBtn(isMobile, DefaultColors.keyword, Icons.search, () {
          Navigator.push(context, SmoothRouter.builder(Search()));
        }),
        _floatingBtn(isMobile, DefaultColors.special, Icons.mic, () {
          Navigator.push(
            context,
            SmoothRouter.builder(RecordPage(widget.storagePath)),
          );
        }),
      ],
    );
  }

  IconButton _floatingBtn(
    bool isMobile,
    Color color,
    IconData icon,
    VoidCallback cb,
  ) {
    return IconButton(
      onPressed: cb,
      icon: Container(
        width: isMobile ? 20.em : 10.em,
        height: isMobile ? 20.em : 10.em,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: DefaultColors.bg,
          size: isMobile ? 15.em : 7.5.em,
        ),
      ),
    );
  }

  Future<void> _setupEncryption() async {
    try {
      await Encryption.init(widget.masterKey, widget.storagePath);
      await IO.init();
    } catch (e) {
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.decryption_err(e.toString())),
            duration: Durations.long1,
          ),
        );
      }
    }
  }
}
