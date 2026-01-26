import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'localizations_en.dart';
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
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

  /// No description provided for @settings_map_saved.
  ///
  /// In zh, this message translates to:
  /// **'地图设置已保存'**
  String get settings_map_saved;

  /// No description provided for @settings_map_reset.
  ///
  /// In zh, this message translates to:
  /// **'地图设置已重置'**
  String get settings_map_reset;

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

  /// No description provided for @settings_map_custom_desc.
  ///
  /// In zh, this message translates to:
  /// **'链接模板（例：https://tile.me/\'{z}/{x}/{y}\'/?key=APIKEY）'**
  String get settings_map_custom_desc;

  /// No description provided for @settings_map_custom_headers.
  ///
  /// In zh, this message translates to:
  /// **'HTTP请求头（例：\'{\"key\": \"xxx\"}\'）'**
  String get settings_map_custom_headers;

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

  /// No description provided for @settings_reset_index.
  ///
  /// In zh, this message translates to:
  /// **'重置索引'**
  String get settings_reset_index;

  /// No description provided for @settings_reset_index_desc.
  ///
  /// In zh, this message translates to:
  /// **'重新建立日志索引'**
  String get settings_reset_index_desc;

  /// No description provided for @settings_asr_model.
  ///
  /// In zh, this message translates to:
  /// **'语音识别设置'**
  String get settings_asr_model;

  /// No description provided for @settings_asr_provider.
  ///
  /// In zh, this message translates to:
  /// **'选择语音识别模型'**
  String get settings_asr_provider;

  /// No description provided for @settings_asr_custom.
  ///
  /// In zh, this message translates to:
  /// **'本地语音识别模型'**
  String get settings_asr_custom;

  /// No description provided for @settings_asr_saved.
  ///
  /// In zh, this message translates to:
  /// **'语音识别设置已保存'**
  String get settings_asr_saved;

  /// No description provided for @settings_asr_reset.
  ///
  /// In zh, this message translates to:
  /// **'语音识别设置已重置'**
  String get settings_asr_reset;

  /// No description provided for @settings_asr_single.
  ///
  /// In zh, this message translates to:
  /// **'单个模型路径（适用于Ctc系列模型）'**
  String get settings_asr_single;

  /// No description provided for @settings_asr_encoder.
  ///
  /// In zh, this message translates to:
  /// **'编码器（encoder）模型路径'**
  String get settings_asr_encoder;

  /// No description provided for @settings_asr_decoder.
  ///
  /// In zh, this message translates to:
  /// **'解码器（decoder）模型路径'**
  String get settings_asr_decoder;

  /// No description provided for @settings_asr_joiner.
  ///
  /// In zh, this message translates to:
  /// **'拼接器（joiner）模型路径（适用于transducer模型）'**
  String get settings_asr_joiner;

  /// No description provided for @settings_asr_tokens.
  ///
  /// In zh, this message translates to:
  /// **'词元文件（tokens.txt）路径'**
  String get settings_asr_tokens;

  /// No description provided for @settings_asr_model_type.
  ///
  /// In zh, this message translates to:
  /// **'模型类型（根据模型名称判断）'**
  String get settings_asr_model_type;

  /// No description provided for @settings_asr_picker_desc.
  ///
  /// In zh, this message translates to:
  /// **'选择模型'**
  String get settings_asr_picker_desc;

  /// No description provided for @settings_asr_download_desc.
  ///
  /// In zh, this message translates to:
  /// **'请自行从sherpa-onnx下载模型，如果懒得搞可以使用预配置'**
  String get settings_asr_download_desc;

  /// No description provided for @settings_asr_download_exp.
  ///
  /// In zh, this message translates to:
  /// **'一般格式为sherpa-onnx-<架构>-<支持的语言>，自行下载解压后即可看到模型（onnx）文件。如果模型文件名称中有int8意味着会牺牲部分精确度换取速度和更小的内存需求。'**
  String get settings_asr_download_exp;

  /// No description provided for @settings_asr_missing_fields.
  ///
  /// In zh, this message translates to:
  /// **'语音识别配置不完整'**
  String get settings_asr_missing_fields;

  /// No description provided for @settings_asr_zh_en_streaming_zipformer.
  ///
  /// In zh, this message translates to:
  /// **'中英双语识别（~500M）'**
  String get settings_asr_zh_en_streaming_zipformer;

  /// No description provided for @settings_asr_zh_en_streaming_paraformer.
  ///
  /// In zh, this message translates to:
  /// **'中英双语识别（~1G）'**
  String get settings_asr_zh_en_streaming_paraformer;

  /// No description provided for @settings_asr_zh_streaming_ctc.
  ///
  /// In zh, this message translates to:
  /// **'中文识别（~700M）'**
  String get settings_asr_zh_streaming_ctc;

  /// No description provided for @settings_asr_en_nemo_ctc.
  ///
  /// In zh, this message translates to:
  /// **'英文识别（~50M）'**
  String get settings_asr_en_nemo_ctc;

  /// No description provided for @settings_zdpp_custom.
  ///
  /// In zh, this message translates to:
  /// **'本地排版模型'**
  String get settings_zdpp_custom;

  /// No description provided for @settings_zdpp_zh_en.
  ///
  /// In zh, this message translates to:
  /// **'中英排版模型'**
  String get settings_zdpp_zh_en;

  /// No description provided for @settings_zdpp_zh_en_int8.
  ///
  /// In zh, this message translates to:
  /// **'中英排版模型（int8）'**
  String get settings_zdpp_zh_en_int8;

  /// No description provided for @settings_zdpp_model.
  ///
  /// In zh, this message translates to:
  /// **'自动排版设置'**
  String get settings_zdpp_model;

  /// No description provided for @settings_zdpp_missing_fields.
  ///
  /// In zh, this message translates to:
  /// **'自动排版配置不完整'**
  String get settings_zdpp_missing_fields;

  /// No description provided for @settings_zdpp_saved.
  ///
  /// In zh, this message translates to:
  /// **'自动排版设置已保存'**
  String get settings_zdpp_saved;

  /// No description provided for @settings_zdpp_reset.
  ///
  /// In zh, this message translates to:
  /// **'自动排版设置已重置'**
  String get settings_zdpp_reset;

  /// No description provided for @settings_zdpp_provider.
  ///
  /// In zh, this message translates to:
  /// **'选择自动排版模型'**
  String get settings_zdpp_provider;

  /// No description provided for @settings_zdpp_path.
  ///
  /// In zh, this message translates to:
  /// **'模型路径'**
  String get settings_zdpp_path;

  /// No description provided for @settings_zdpp_download_desc.
  ///
  /// In zh, this message translates to:
  /// **'请自行从sherpa-onnx下载模型，如果懒得搞可以使用预配置'**
  String get settings_zdpp_download_desc;

  /// No description provided for @settings_zdpp_download_exp.
  ///
  /// In zh, this message translates to:
  /// **'sherpa-onnx一共就提供了三个模型，自己看着办吧'**
  String get settings_zdpp_download_exp;

  /// No description provided for @download_title.
  ///
  /// In zh, this message translates to:
  /// **'下载'**
  String get download_title;

  /// No description provided for @download_perc.
  ///
  /// In zh, this message translates to:
  /// **'{a}：{b}%'**
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

  /// No description provided for @cover_desc.
  ///
  /// In zh, this message translates to:
  /// **'为日志添加标题和封面'**
  String get cover_desc;

  /// No description provided for @cover_desc_hint.
  ///
  /// In zh, this message translates to:
  /// **'输入一个emoji'**
  String get cover_desc_hint;

  /// No description provided for @metadata_title.
  ///
  /// In zh, this message translates to:
  /// **'导入（WAV文件，pcm_s16le格式）'**
  String get metadata_title;

  /// No description provided for @metadata_select_file.
  ///
  /// In zh, this message translates to:
  /// **'选择音频文件'**
  String get metadata_select_file;

  /// No description provided for @metadata_no_file_selected.
  ///
  /// In zh, this message translates to:
  /// **'未选择文件'**
  String get metadata_no_file_selected;

  /// No description provided for @metadata_duration.
  ///
  /// In zh, this message translates to:
  /// **'时长'**
  String get metadata_duration;

  /// No description provided for @metadata_duration_error.
  ///
  /// In zh, this message translates to:
  /// **'获取时长失败: {error}'**
  String metadata_duration_error(Object error);

  /// No description provided for @metadata_select_datetime.
  ///
  /// In zh, this message translates to:
  /// **'选择日期和时间'**
  String get metadata_select_datetime;

  /// No description provided for @metadata_select_date.
  ///
  /// In zh, this message translates to:
  /// **'选择日期'**
  String get metadata_select_date;

  /// No description provided for @metadata_select_time.
  ///
  /// In zh, this message translates to:
  /// **'选择时间'**
  String get metadata_select_time;

  /// No description provided for @metadata_title_label.
  ///
  /// In zh, this message translates to:
  /// **'标题'**
  String get metadata_title_label;

  /// No description provided for @metadata_title_required.
  ///
  /// In zh, this message translates to:
  /// **'标题不能为空'**
  String get metadata_title_required;

  /// No description provided for @metadata_location_optional.
  ///
  /// In zh, this message translates to:
  /// **'位置信息（可选）'**
  String get metadata_location_optional;

  /// No description provided for @metadata_latitude.
  ///
  /// In zh, this message translates to:
  /// **'纬度'**
  String get metadata_latitude;

  /// No description provided for @metadata_latitude_hint.
  ///
  /// In zh, this message translates to:
  /// **'例如: 34.0522'**
  String get metadata_latitude_hint;

  /// No description provided for @metadata_invalid_latitude.
  ///
  /// In zh, this message translates to:
  /// **'无效纬度（-90~90）'**
  String get metadata_invalid_latitude;

  /// No description provided for @metadata_longitude.
  ///
  /// In zh, this message translates to:
  /// **'经度'**
  String get metadata_longitude;

  /// No description provided for @metadata_longitude_hint.
  ///
  /// In zh, this message translates to:
  /// **'例如: -118.2437'**
  String get metadata_longitude_hint;

  /// No description provided for @metadata_invalid_longitude.
  ///
  /// In zh, this message translates to:
  /// **'无效经度（-180~180）'**
  String get metadata_invalid_longitude;

  /// No description provided for @metadata_cover_label.
  ///
  /// In zh, this message translates to:
  /// **'封面（单个字符）'**
  String get metadata_cover_label;

  /// No description provided for @metadata_cover_required.
  ///
  /// In zh, this message translates to:
  /// **'请输入一个字符'**
  String get metadata_cover_required;

  /// No description provided for @metadata_cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get metadata_cancel;

  /// No description provided for @metadata_import.
  ///
  /// In zh, this message translates to:
  /// **'导入'**
  String get metadata_import;

  /// No description provided for @metadata_duration_missing.
  ///
  /// In zh, this message translates to:
  /// **'无法获取音频时长，请重新选择文件'**
  String get metadata_duration_missing;

  /// No description provided for @metadata_save_error.
  ///
  /// In zh, this message translates to:
  /// **'导入失败：{msg}'**
  String metadata_save_error(Object msg);

  /// No description provided for @metadata_edit_title.
  ///
  /// In zh, this message translates to:
  /// **'编辑元数据'**
  String get metadata_edit_title;

  /// No description provided for @metadata_save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get metadata_save;

  /// No description provided for @metadata_transcript_label.
  ///
  /// In zh, this message translates to:
  /// **'转录文本'**
  String get metadata_transcript_label;

  /// No description provided for @metadata_transcript_hint.
  ///
  /// In zh, this message translates to:
  /// **'输入音频转录文本'**
  String get metadata_transcript_hint;

  /// No description provided for @metadata_missing_asr_setting.
  ///
  /// In zh, this message translates to:
  /// **'未配置语音识别'**
  String get metadata_missing_asr_setting;

  /// No description provided for @metadata_zdpp.
  ///
  /// In zh, this message translates to:
  /// **'自动排版'**
  String get metadata_zdpp;

  /// No description provided for @metadata_rebuild_transcript.
  ///
  /// In zh, this message translates to:
  /// **'重新识别语音'**
  String get metadata_rebuild_transcript;

  /// No description provided for @untitled_cd.
  ///
  /// In zh, this message translates to:
  /// **'未命名磁带'**
  String get untitled_cd;

  /// No description provided for @playlist_title.
  ///
  /// In zh, this message translates to:
  /// **'选中的记录（{len}）'**
  String playlist_title(Object len);

  /// No description provided for @search_hint.
  ///
  /// In zh, this message translates to:
  /// **'搜索标题或内容...'**
  String get search_hint;

  /// No description provided for @search_results_count.
  ///
  /// In zh, this message translates to:
  /// **'找到{n}个匹配{needle}的结果'**
  String search_results_count(Object n, Object needle);

  /// No description provided for @search_no_results.
  ///
  /// In zh, this message translates to:
  /// **'未找到匹配结果'**
  String get search_no_results;

  /// No description provided for @decryption_err.
  ///
  /// In zh, this message translates to:
  /// **'解密失败：{err}，请检查主密钥是否正确'**
  String decryption_err(Object err);

  /// No description provided for @transcript_empty.
  ///
  /// In zh, this message translates to:
  /// **'未识别到文本'**
  String get transcript_empty;

  /// No description provided for @missing_map_settings.
  ///
  /// In zh, this message translates to:
  /// **'未配置地图源，地理视图不可用'**
  String get missing_map_settings;

  /// No description provided for @missing_asr_settings.
  ///
  /// In zh, this message translates to:
  /// **'未配置转录模型，语音转文字不可用'**
  String get missing_asr_settings;

  /// No description provided for @missing_zdpp_settings.
  ///
  /// In zh, this message translates to:
  /// **'未配置自动排版模型，自动排版不可用'**
  String get missing_zdpp_settings;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
