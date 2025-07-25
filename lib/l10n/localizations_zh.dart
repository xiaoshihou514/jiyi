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
  String get settings_map_custom_desc =>
      '链接模板（例：https://tile.me/{z}/{x}/{y}/?key=APIKEY）';

  @override
  String get settings_map_custom_headers => 'HTTP请求头（例：{\"key\": \"xxx\"}）';

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
  String get settings_reset_index => '重置索引';

  @override
  String get settings_reset_index_desc => '重新建立日志索引';

  @override
  String get settings_tts_model => '语音转文字设置';

  @override
  String get settings_tts_saved => '语音转文字设置已保存';

  @override
  String get settings_tts_encoder => '编码器模型路径';

  @override
  String get settings_tts_decoder => '解码器模型路径';

  @override
  String get settings_tts_joiner => '拼接器模型路径';

  @override
  String get settings_tts_tokens => '词元文件路径';

  @override
  String get settings_tts_model_type => '模型类型（例：zipformer）';

  @override
  String get settings_tts_picker_desc => '选择模型';

  @override
  String get settings_tts_download_desc => '请自行从sherpa-onnx下载模型';

  @override
  String get settings_tts_download_exp =>
      '一般格式为xxx-streaming-zipformer-语言，自行下载解压后即可看到模型（onnx）文件。一般来说中端手机跑500M的模型是没什么问题的。';

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

  @override
  String get cover_desc => '为日志添加标题和封面';

  @override
  String get cover_desc_hint => '输入一个emoji';

  @override
  String get metadata_title => '导入（WAV文件，pcm_s16le格式）';

  @override
  String get metadata_select_file => '选择音频文件';

  @override
  String get metadata_no_file_selected => '未选择文件';

  @override
  String get metadata_duration => '时长';

  @override
  String metadata_duration_error(Object error) {
    return '获取时长失败: $error';
  }

  @override
  String get metadata_select_datetime => '选择日期和时间';

  @override
  String get metadata_select_date => '选择日期';

  @override
  String get metadata_select_time => '选择时间';

  @override
  String get metadata_title_label => '标题';

  @override
  String get metadata_title_required => '标题不能为空';

  @override
  String get metadata_location_optional => '位置信息（可选）';

  @override
  String get metadata_latitude => '纬度';

  @override
  String get metadata_latitude_hint => '例如: 34.0522';

  @override
  String get metadata_invalid_latitude => '无效纬度（-90~90）';

  @override
  String get metadata_longitude => '经度';

  @override
  String get metadata_longitude_hint => '例如: -118.2437';

  @override
  String get metadata_invalid_longitude => '无效经度（-180~180）';

  @override
  String get metadata_cover_label => '封面（单个字符）';

  @override
  String get metadata_cover_required => '请输入一个字符';

  @override
  String get metadata_cancel => '取消';

  @override
  String get metadata_import => '导入';

  @override
  String get metadata_duration_missing => '无法获取音频时长，请重新选择文件';

  @override
  String metadata_save_error(Object msg) {
    return '导入失败：$msg';
  }

  @override
  String get untitled_cd => '未命名磁带';

  @override
  String playlist_title(Object len) {
    return '选中的记录（$len）';
  }

  @override
  String get search_hint => '搜索标题或内容...';

  @override
  String search_results_count(Object n, Object needle) {
    return '找到$n个匹配$needle的结果';
  }

  @override
  String get search_no_results => '未找到匹配结果';

  @override
  String decryption_err(Object err) {
    return '解密失败：$err，请检查主密钥是否正确';
  }
}
