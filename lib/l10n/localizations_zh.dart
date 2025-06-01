// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get welcome_1 => '你所记录的';

  @override
  String get welcome_2_1 => '就是';

  @override
  String get welcome_2_2 => '你的回忆';

  @override
  String get welcome_3 => '让心事沉入琥珀';

  @override
  String get welcome_4_1 => '封存';

  @override
  String get welcome_4_2 => '此刻';

  @override
  String get mk_title => '创建主密钥';

  @override
  String get mk_desc => '用来解密您的语音日志的密钥。若录音文件被转移到其他设备，需重新输入该密钥方可读取录音。';

  @override
  String get mk_warn_title => '请务必牢记主密钥！';

  @override
  String get mk_warn_desc_1 => '主密钥不可重置或找回';

  @override
  String get mk_warn_desc_2 => '，一旦丢失，您将永久无法访问已加密的语音内容。';

  @override
  String get st_title => '选择储存路径';

  @override
  String get st_desc => '所有文件均储存在本地，用户可以自行将其备份到云端或其他设备。';

  @override
  String get st_hint => '选择文件夹';

  @override
  String get st_path_placeholder => '您还未选择储存路径';

  @override
  String get st_path_prefix => '您已选择：';

  @override
  String get auth_unlock_reason => '验证身份以解锁';

  @override
  String get auth_unlock_err => '身份认证时出现错误';

  @override
  String get auth_linux_unknown_user => '未知用户';

  @override
  String get auth_linux_cancel => '取消';

  @override
  String get auth_linux_enter => '确定';

  @override
  String get mic_error_title => '麦克风初始化失败';

  @override
  String get mic_error_ok => '啊这';

  @override
  String get settings_map => '地图设置';

  @override
  String get settings_map_provider => '选择地图源';

  @override
  String get settings_map_local => '本地地图';

  @override
  String get settings_map_osm => 'OpenStreetMap';

  @override
  String get settings_map_amap => '高德地图（闭源）';

  @override
  String get settings_map_amap_satelite => '高德地图卫星图（闭源）';

  @override
  String get settings_map_custom => '其他在线地图源';

  @override
  String get settings_map_other => '其他地图';

  @override
  String get settings_map_loc_path => '原始栅格文件路径';

  @override
  String get settings_map_loc_pattern => '查找规则（例：{z}/{x}-{y}.png）';

  @override
  String get settings_map_max_zoom => '最大缩放比例';

  @override
  String get settings_map_save_success => '地图设置已保存';

  @override
  String get settings_map_settings_dne => '您还未配置地图源，请在设置配置';

  @override
  String get settings_map_loc_missing_field => '有些参数还未设置，请检查后重试';

  @override
  String get settings_map_pull_desc => '你可以从以下网站下载已打包的栅格文件（最大支持10倍放大）';

  @override
  String settings_map_loc_down_src(Object src) {
    return '自$src下载地图';
  }

  @override
  String get settings_reset => '重置应用状态';

  @override
  String get settings_reset_mk => '重置主密钥';

  @override
  String get settings_reset_mk_desc => '在下次打开应用时重新输入主密钥';

  @override
  String get settings_reset_spath => '重置储存路径';

  @override
  String get settings_reset_spath_desc => '在下次打开应用时重新输入储存路径';

  @override
  String get settings_reset_success => '已重置';

  @override
  String get download_title => '栅格文件下载';

  @override
  String download_perc(Object a, Object b) {
    return '$a.zip：$b%';
  }

  @override
  String get download_extracting => '解压中';

  @override
  String get download_done => '完成';

  @override
  String get download_exit => '完成';
}
