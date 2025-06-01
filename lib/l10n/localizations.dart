import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('zh')];

  /// No description provided for @welcome_1.
  ///
  /// In zh, this message translates to:
  /// **'你所记录的'**
  String get welcome_1;

  /// No description provided for @welcome_2_1.
  ///
  /// In zh, this message translates to:
  /// **'就是'**
  String get welcome_2_1;

  /// No description provided for @welcome_2_2.
  ///
  /// In zh, this message translates to:
  /// **'你的回忆'**
  String get welcome_2_2;

  /// No description provided for @welcome_3.
  ///
  /// In zh, this message translates to:
  /// **'让心事沉入琥珀'**
  String get welcome_3;

  /// No description provided for @welcome_4_1.
  ///
  /// In zh, this message translates to:
  /// **'封存'**
  String get welcome_4_1;

  /// No description provided for @welcome_4_2.
  ///
  /// In zh, this message translates to:
  /// **'此刻'**
  String get welcome_4_2;

  /// No description provided for @mk_title.
  ///
  /// In zh, this message translates to:
  /// **'创建主密钥'**
  String get mk_title;

  /// No description provided for @mk_desc.
  ///
  /// In zh, this message translates to:
  /// **'用来解密您的语音日志的密钥。若录音文件被转移到其他设备，需重新输入该密钥方可读取录音。'**
  String get mk_desc;

  /// No description provided for @mk_warn_title.
  ///
  /// In zh, this message translates to:
  /// **'请务必牢记主密钥！'**
  String get mk_warn_title;

  /// No description provided for @mk_warn_desc_1.
  ///
  /// In zh, this message translates to:
  /// **'主密钥不可重置或找回'**
  String get mk_warn_desc_1;

  /// No description provided for @mk_warn_desc_2.
  ///
  /// In zh, this message translates to:
  /// **'，一旦丢失，您将永久无法访问已加密的语音内容。'**
  String get mk_warn_desc_2;

  /// No description provided for @st_title.
  ///
  /// In zh, this message translates to:
  /// **'选择储存路径'**
  String get st_title;

  /// No description provided for @st_desc.
  ///
  /// In zh, this message translates to:
  /// **'所有文件均储存在本地，用户可以自行将其备份到云端或其他设备。'**
  String get st_desc;

  /// No description provided for @st_hint.
  ///
  /// In zh, this message translates to:
  /// **'选择文件夹'**
  String get st_hint;

  /// No description provided for @st_path_placeholder.
  ///
  /// In zh, this message translates to:
  /// **'您还未选择储存路径'**
  String get st_path_placeholder;

  /// No description provided for @st_path_prefix.
  ///
  /// In zh, this message translates to:
  /// **'您已选择：'**
  String get st_path_prefix;

  /// No description provided for @auth_unlock_reason.
  ///
  /// In zh, this message translates to:
  /// **'验证身份以解锁'**
  String get auth_unlock_reason;

  /// No description provided for @auth_unlock_err.
  ///
  /// In zh, this message translates to:
  /// **'身份认证时出现错误'**
  String get auth_unlock_err;

  /// No description provided for @auth_linux_unknown_user.
  ///
  /// In zh, this message translates to:
  /// **'未知用户'**
  String get auth_linux_unknown_user;

  /// No description provided for @auth_linux_cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get auth_linux_cancel;

  /// No description provided for @auth_linux_enter.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get auth_linux_enter;

  /// No description provided for @mic_error_title.
  ///
  /// In zh, this message translates to:
  /// **'麦克风初始化失败'**
  String get mic_error_title;

  /// No description provided for @mic_error_ok.
  ///
  /// In zh, this message translates to:
  /// **'啊这'**
  String get mic_error_ok;

  /// No description provided for @settings_map.
  ///
  /// In zh, this message translates to:
  /// **'地图设置'**
  String get settings_map;

  /// No description provided for @settings_map_provider.
  ///
  /// In zh, this message translates to:
  /// **'选择地图源'**
  String get settings_map_provider;

  /// No description provided for @settings_map_local.
  ///
  /// In zh, this message translates to:
  /// **'本地地图'**
  String get settings_map_local;

  /// No description provided for @settings_map_osm.
  ///
  /// In zh, this message translates to:
  /// **'OpenStreetMap'**
  String get settings_map_osm;

  /// No description provided for @settings_map_amap.
  ///
  /// In zh, this message translates to:
  /// **'高德地图（闭源）'**
  String get settings_map_amap;

  /// No description provided for @settings_map_amap_satelite.
  ///
  /// In zh, this message translates to:
  /// **'高德地图卫星图（闭源）'**
  String get settings_map_amap_satelite;

  /// No description provided for @settings_map_custom.
  ///
  /// In zh, this message translates to:
  /// **'其他在线地图源'**
  String get settings_map_custom;

  /// No description provided for @settings_map_other.
  ///
  /// In zh, this message translates to:
  /// **'其他地图'**
  String get settings_map_other;

  /// No description provided for @settings_map_loc_path.
  ///
  /// In zh, this message translates to:
  /// **'原始栅格文件路径'**
  String get settings_map_loc_path;

  /// No description provided for @settings_map_loc_pattern.
  ///
  /// In zh, this message translates to:
  /// **'查找规则（例：\'{z}/{x}-{y}.png\'）'**
  String get settings_map_loc_pattern;

  /// No description provided for @settings_map_max_zoom.
  ///
  /// In zh, this message translates to:
  /// **'最大缩放比例'**
  String get settings_map_max_zoom;

  /// No description provided for @settings_map_save_success.
  ///
  /// In zh, this message translates to:
  /// **'地图设置已保存'**
  String get settings_map_save_success;

  /// No description provided for @settings_map_settings_dne.
  ///
  /// In zh, this message translates to:
  /// **'您还未配置地图源，请在设置配置'**
  String get settings_map_settings_dne;

  /// No description provided for @settings_map_loc_missing_field.
  ///
  /// In zh, this message translates to:
  /// **'有些参数还未设置，请检查后重试'**
  String get settings_map_loc_missing_field;

  /// No description provided for @settings_map_pull_desc.
  ///
  /// In zh, this message translates to:
  /// **'你可以从以下网站下载已打包的栅格文件（最大支持10倍放大）'**
  String get settings_map_pull_desc;

  /// No description provided for @settings_map_loc_down_src.
  ///
  /// In zh, this message translates to:
  /// **'自{src}下载地图'**
  String settings_map_loc_down_src(Object src);

  /// No description provided for @settings_reset.
  ///
  /// In zh, this message translates to:
  /// **'重置应用状态'**
  String get settings_reset;

  /// No description provided for @settings_reset_mk.
  ///
  /// In zh, this message translates to:
  /// **'重置主密钥'**
  String get settings_reset_mk;

  /// No description provided for @settings_reset_mk_desc.
  ///
  /// In zh, this message translates to:
  /// **'在下次打开应用时重新输入主密钥'**
  String get settings_reset_mk_desc;

  /// No description provided for @settings_reset_spath.
  ///
  /// In zh, this message translates to:
  /// **'重置储存路径'**
  String get settings_reset_spath;

  /// No description provided for @settings_reset_spath_desc.
  ///
  /// In zh, this message translates to:
  /// **'在下次打开应用时重新输入储存路径'**
  String get settings_reset_spath_desc;

  /// No description provided for @settings_reset_success.
  ///
  /// In zh, this message translates to:
  /// **'已重置'**
  String get settings_reset_success;

  /// No description provided for @download_title.
  ///
  /// In zh, this message translates to:
  /// **'栅格文件下载'**
  String get download_title;

  /// No description provided for @download_perc.
  ///
  /// In zh, this message translates to:
  /// **'{a}.zip：{b}%'**
  String download_perc(Object a, Object b);

  /// No description provided for @download_extracting.
  ///
  /// In zh, this message translates to:
  /// **'解压中'**
  String get download_extracting;

  /// No description provided for @download_done.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get download_done;

  /// No description provided for @download_exit.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get download_exit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
