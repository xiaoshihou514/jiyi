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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('zh')
  ];

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
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
