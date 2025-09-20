// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome_1 => 'What you record';

  @override
  String get welcome_2_1 => 'is';

  @override
  String get welcome_2_2 => ' memory';

  @override
  String get welcome_3 => 'Sink your mind';

  @override
  String get welcome_4_1 => 'Save';

  @override
  String get welcome_4_2 => ' the present';

  @override
  String get mk_title => 'Create Master Key';

  @override
  String get mk_desc =>
      'A key used to decrypt your voice logs. If the recordings are transferred to another device, the key must be re-entered to access them.';

  @override
  String get mk_warn_title => 'Be sure to remember your master key!';

  @override
  String get mk_warn_desc_1 => 'The master key cannot be reset or recovered';

  @override
  String get mk_warn_desc_2 =>
      ', and if lost, you will permanently lose access to your encrypted recordings.';

  @override
  String get st_title => 'Select Storage Path';

  @override
  String get st_desc =>
      'All files are stored locally. You may back them up to the cloud or another device manually.';

  @override
  String get st_hint => 'Choose Folder';

  @override
  String get st_path_placeholder => 'No storage path selected yet';

  @override
  String get st_path_prefix => 'Selected path: ';

  @override
  String get auth_unlock_reason => 'Authenticate to unlock';

  @override
  String get auth_unlock_err => 'Authentication error occurred';

  @override
  String get auth_linux_unknown_user => 'Unknown user';

  @override
  String get auth_linux_cancel => 'Cancel';

  @override
  String get auth_linux_enter => 'Confirm';

  @override
  String get mic_error_title => 'Microphone initialization failed';

  @override
  String get mic_error_ok => 'Oops';

  @override
  String get settings_map => 'Map Settings';

  @override
  String get settings_map_provider => 'Choose map source';

  @override
  String get settings_map_local => 'Local map';

  @override
  String get settings_map_osm => 'OpenStreetMap';

  @override
  String get settings_map_amap => 'Amap (proprietary)';

  @override
  String get settings_map_amap_satelite => 'Amap Satellite (proprietary)';

  @override
  String get settings_map_custom => 'Other online map sources';

  @override
  String get settings_map_loc_path => 'Local raster file path';

  @override
  String get settings_map_loc_pattern => 'Pattern (e.g., {z}/{x}-{y}.png)';

  @override
  String get settings_map_max_zoom => 'Maximum zoom level';

  @override
  String get settings_map_save_success => 'Map settings saved';

  @override
  String get settings_map_settings_dne =>
      'Map source not configured, please set it in settings';

  @override
  String get settings_map_loc_missing_field =>
      'Some parameters are missing, please check and try again';

  @override
  String get settings_map_pull_desc =>
      'You can download packaged raster files from the sites below (up to 10x zoom)';

  @override
  String settings_map_loc_down_src(Object src) {
    return 'Download map from $src';
  }

  @override
  String get settings_map_custom_desc =>
      'URL template (e.g., https://tile.me/{z}/{x}/{y}/?key=APIKEY)';

  @override
  String get settings_map_custom_headers =>
      'HTTP headers (e.g., {\"key\": \"xxx\"})';

  @override
  String get settings_reset => 'Reset application state';

  @override
  String get settings_reset_mk => 'Reset master key';

  @override
  String get settings_reset_mk_desc =>
      'Re-enter the master key the next time the app is opened';

  @override
  String get settings_reset_spath => 'Reset storage path';

  @override
  String get settings_reset_spath_desc =>
      'Re-select storage path the next time the app is opened';

  @override
  String get settings_reset_success => 'Reset successful';

  @override
  String get settings_reset_index => 'Reset index';

  @override
  String get settings_reset_index_desc => 'Rebuild the log index';

  @override
  String get settings_asr_model => 'ASR settings';

  @override
  String get settings_asr_provider => '选择语音识别模型';

  @override
  String get settings_asr_custom => '本地语音识别模型';

  @override
  String get settings_asr_saved => 'ASR settings saved';

  @override
  String get settings_asr_single => '单个模型路径（适用于Ctc系列模型）';

  @override
  String get settings_asr_encoder => 'Encoder model path';

  @override
  String get settings_asr_decoder => 'Decoder model path';

  @override
  String get settings_asr_joiner => 'Joiner model path';

  @override
  String get settings_asr_tokens => 'Token file path';

  @override
  String get settings_asr_model_type => 'Model type (e.g., zipformer)';

  @override
  String get settings_asr_picker_desc => 'Select model';

  @override
  String get settings_asr_download_desc =>
      'Please download models manually from sherpa-onnx';

  @override
  String get settings_asr_download_exp =>
      'The format is usually xxx-streaming-zipformer-language, after you have downloaded and extracted the archive you should see the model (onnx) files. A modest phone should be able to run a 500M model.';

  @override
  String get settings_asr_missing_fields => '语音识别配置不完整';

  @override
  String get settings_asr_zh_en_streaming_zipformer => '中英双语识别（~500M）';

  @override
  String get settings_asr_zh_en_streaming_paraformer => '中英双语识别（~1G）';

  @override
  String get settings_asr_zh_streaming_ctc => '中文识别（~700M）';

  @override
  String get settings_asr_en_nemo_ctc => '英文识别（~50M）';

  @override
  String get settings_llm_model => '大模型设置';

  @override
  String get settings_llm_provider => '选择大模型';

  @override
  String get settings_llm_custom => '本地大语言模型';

  @override
  String get settings_llm_qwen3_1_7B => '千问3-1.7B';

  @override
  String get settings_llm_qwen3_4B => '千问3-4B（需要大量内存）';

  @override
  String get settings_llm_root_picker_desc => '选择模型所在文件夹';

  @override
  String get settings_llm_root_picker_cover => '选择文件夹';

  @override
  String get settings_llm_prompt_desc => '提示词';

  @override
  String get settings_llm_saved => '大模型设置已保存';

  @override
  String get settings_zdpp_custom => '本地排版模型';

  @override
  String get settings_zdpp_zh_en => '中英排版模型';

  @override
  String get settings_zdpp_zh_en_int8 => '中英排版模型（int8）';

  @override
  String get settings_zdpp_model => '自动排版设置';

  @override
  String get settings_zdpp_missing_fields => '自动排版配置不完整';

  @override
  String get settings_zdpp_saved => '自动排版设置已保存';

  @override
  String get settings_zdpp_provider => '选择自动排版模型';

  @override
  String get settings_zdpp_path => '模型路径';

  @override
  String get settings_zdpp_download_desc => '请自行从sherpa-onnx下载模型，如果懒得搞可以使用预配置';

  @override
  String get settings_zdpp_download_exp => 'sherpa-onnx一共就提供了三个模型，自己看着办吧';

  @override
  String get download_title => 'Download';

  @override
  String download_perc(Object a, Object b) {
    return '$a: $b%';
  }

  @override
  String get download_extracting => 'Extracting';

  @override
  String get download_done => 'Done';

  @override
  String get download_exit => 'Completed';

  @override
  String get cover_desc => 'Add a title and cover to the log';

  @override
  String get cover_desc_hint => 'Enter an emoji';

  @override
  String get metadata_title => 'Import (WAV file, pcm_s16le format)';

  @override
  String get metadata_select_file => 'Select audio file';

  @override
  String get metadata_no_file_selected => 'No file selected';

  @override
  String get metadata_duration => 'Duration';

  @override
  String metadata_duration_error(Object error) {
    return 'Failed to get duration: $error';
  }

  @override
  String get metadata_select_datetime => 'Select date and time';

  @override
  String get metadata_select_date => 'Select date';

  @override
  String get metadata_select_time => 'Select time';

  @override
  String get metadata_title_label => 'Title';

  @override
  String get metadata_title_required => 'Title cannot be empty';

  @override
  String get metadata_location_optional => 'Location (optional)';

  @override
  String get metadata_latitude => 'Latitude';

  @override
  String get metadata_latitude_hint => 'e.g., 34.0522';

  @override
  String get metadata_invalid_latitude => 'Invalid latitude (-90 to 90)';

  @override
  String get metadata_longitude => 'Longitude';

  @override
  String get metadata_longitude_hint => 'e.g., -118.2437';

  @override
  String get metadata_invalid_longitude => 'Invalid longitude (-180 to 180)';

  @override
  String get metadata_cover_label => 'Cover (single character)';

  @override
  String get metadata_cover_required => 'Please enter one character';

  @override
  String get metadata_cancel => 'Cancel';

  @override
  String get metadata_import => 'Import';

  @override
  String get metadata_duration_missing =>
      'Unable to retrieve audio duration, please select the file again';

  @override
  String metadata_save_error(Object msg) {
    return 'Import failed: $msg';
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
  String get untitled_cd => 'Untitled Tape';

  @override
  String playlist_title(Object len) {
    return 'Entries selected ($len)';
  }

  @override
  String get search_hint => 'Search titles or content...';

  @override
  String search_results_count(Object n, Object needle) {
    return '$n results found for $needle';
  }

  @override
  String get search_no_results => 'No results found';

  @override
  String decryption_err(Object err) {
    return 'Decryption failed: $err. Please check if the master key is correct';
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
