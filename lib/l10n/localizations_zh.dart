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
  String get settings_asr_model => '语音识别设置';

  @override
  String get settings_asr_provider => '选择语音识别模型';

  @override
  String get settings_asr_custom => '本地语音识别模型';

  @override
  String get settings_asr_saved => '语音识别设置已保存';

  @override
  String get settings_asr_encoder => '编码器（encoder）模型路径';

  @override
  String get settings_asr_decoder => '解码器（decoder）模型路径';

  @override
  String get settings_asr_joiner => '拼接器（joiner）模型路径';

  @override
  String get settings_asr_tokens => '词元文件（tokens.txt）路径';

  @override
  String get settings_asr_model_type => '模型类型（例：zipformer）';

  @override
  String get settings_asr_picker_desc => '选择模型';

  @override
  String get settings_asr_download_desc => '请自行从sherpa-onnx下载模型，如果懒得搞可以使用预配置';

  @override
  String get settings_asr_download_exp =>
      '一般格式为xxx-streaming-zipformer-语言，自行下载解压后即可看到模型（onnx）文件。一般来说中端手机跑500M的模型是没什么问题的。';

  @override
  String get settings_asr_zh_en_streaming_zipformer => '中英双语识别';

  @override
  String get settings_llm_zdpp_model => '自动排版设置';

  @override
  String get settings_llm_zdpp_desc => '自动排版会调用大语言模型帮你把语音内容加上标点符号、自动分段';

  @override
  String get settings_llm_zdpp_provider => '选择大模型';

  @override
  String get settings_llm_zdpp_custom => '本地大语言模型';

  @override
  String get settings_llm_zdpp_qwen3_1_7B => '千问3-1.7B';

  @override
  String get settings_llm_zdpp_qwen3_4B => '千问3-4B（需要大量内存）';

  @override
  String get settings_llm_zdpp_root_picker_desc => '选择模型所在文件夹';

  @override
  String get settings_llm_zdpp_root_picker_cover => '选择文件夹';

  @override
  String get settings_llm_zdpp_prompt_desc => '自动排版提示词';

  @override
  String get settings_llm_zdpp_saved => '自动排版设置已保存';

  @override
  String get download_title => '下载';

  @override
  String download_perc(Object a, Object b) {
    return '$a：$b%';
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
  String get metadata_edit_title => '编辑元数据';

  @override
  String get metadata_save => '保存';

  @override
  String get metadata_transcript_label => '转录文本';

  @override
  String get metadata_transcript_hint => '输入音频转录文本';

  @override
  String get metadata_missing_llm_setting => '未配置自动排版';

  @override
  String get metadata_missing_asr_setting => '未配置语音识别';

  @override
  String get metadata_zdpp => '自动排版';

  @override
  String get metadata_rebuild_transcript => '重新识别语音';

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

  @override
  String get transcript_empty => '未识别到文本';

  @override
  String get asr_opt_prompt =>
      '你是一个文本整理专家，请严格按照以下规则处理输入文本。任何偏离都将导致错误。\n【核心规则】\n绝对忠于原意，仅修改表达形式。不添加不存在的信息，不删除原有的内容。\n【必须执行的操作】\n1.  删除填充词：立即删除“呃、额、嗯、这个、那个、然后的话、反正、就是、嘛、啥的吧”等所有无意义的语气词和填充词。\n2.  按以下规则修正以下错误：\n合并重复：立即合并所有重复字词，如“过了一遍”不能变为“过了一遍一遍”。\n修正别字（重点）：你必须根据上下文修正发音类似的错别字。比如：\n“修好” -> “消耗”\n“游好” -> “友好”\n“二千” -> “而浅” 或 “而且浅”\n“一部” -> “一步”\n推断含义：将“阿巴阿巴”等无意义音节替换为“[语意不清]”。将逻辑混乱的句子尽力通顺。\n3.  添加标点与分句：你必须严格分句，一个逗号只表示一个短暂停顿，一个句号表示一个完整语义的结束。确保每句话都独立通顺。\n4.  调整语序：将口语化的、倒装的语序调整为标准的书面语序。\n【严禁出现的问题 - 负面清单】\n严禁保留任何填充词。\n严禁忽略同音别字，必须修正。\n严禁输出冗长、不分句的段落。\n严禁改变原文的核心事实和情感。\n严禁输出处理后的文本以外的内容。\n【输出示例】\n错误示例：“如果你想推进中日游的话” (未修正别字、逻辑跳跃)\n正确示例：“如果你想推进中日友好的话。”';

  @override
  String get missing_map_settings => '未配置地图源，地理视图不可用';

  @override
  String get missing_asr_settings => '未配置转录模型，语音转文字不可用';

  @override
  String get missing_llm_settings => '未配置自动排版模型，自动排版不可用';
}
