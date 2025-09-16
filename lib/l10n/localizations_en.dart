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
  String get settings_tts_model => 'STT settings';

  @override
  String get settings_tts_provider => '选择语音识别模型';

  @override
  String get settings_tts_custom => '本地语音识别模型';

  @override
  String get settings_tts_saved => 'STT settings saved';

  @override
  String get settings_tts_encoder => 'Encoder model path';

  @override
  String get settings_tts_decoder => 'Decoder model path';

  @override
  String get settings_tts_joiner => 'Joiner model path';

  @override
  String get settings_tts_tokens => 'Token file path';

  @override
  String get settings_tts_model_type => 'Model type (e.g., zipformer)';

  @override
  String get settings_tts_picker_desc => 'Select model';

  @override
  String get settings_tts_download_desc =>
      'Please download models manually from sherpa-onnx';

  @override
  String get settings_tts_download_exp =>
      'The format is usually xxx-streaming-zipformer-language, after you have downloaded and extracted the archive you should see the model (onnx) files. A modest phone should be able to run a 500M model.';

  @override
  String get settings_tts_zh_en_streaming_zipformer => '中英双语识别';

  @override
  String get settings_llm_zdpp_model => '自动排版设置';

  @override
  String get settings_llm_zdpp_desc => '自动排版会调用大语言模型帮你把语音内容加上标点符号、自动分段';

  @override
  String get settings_llm_zdpp_provider => '选择大模型';

  @override
  String get settings_llm_zdpp_custom => '本地大语言模型';

  @override
  String get settings_llm_zdpp_qwen3_1_5B => '千问3-1.5B';

  @override
  String get settings_llm_zdpp_root_picker_desc => '选择模型所在文件夹';

  @override
  String get settings_llm_zdpp_root_picker_cover => '选择文件夹';

  @override
  String get settings_llm_zdpp_prompt_desc => '自动排版提示词';

  @override
  String get settings_llm_zdpp_saved => '自动排版设置已保存';

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
  String get metadata_zdpp => '自动排版';

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
  String get tts_opt_prompt =>
      '你是一个文本整理专家。请严格按照以下规则处理用户输入：\n1.  删除填充词：删除所有“呃”、“额”、“嗯”、“这个”、“那个”等无意义词。\n2.  修正错误：合并重复的字词（如“其其其”改为“其”），修正明显的错别字（如“键键期”改为“关键期”）。\n3.  添加标点：在合适的位置添加句号（。）、逗号（，）、顿号（、），使其成为通顺的句子。\n4.  调整语序：微调语序，使其符合中文书面语习惯。\n5.  保持原意：绝对忠实于原文的语义，不添加原文中没有的信息，不删去原文中有的句子\n请参考以下示例进行操作\n【用户输入】\n故故博物馆救称为紫禁城臣位于北京市中心是中国明明清两代的皇家宫殿也是世界上现现现存存LY最大保存最最为完整的物质结构结构构ER古建县主朱主布主席群之一之之一\n【修正输出】\n故宫博物馆旧称为紫禁城，位于北京市中心，是中国明清两代的皇家宫殿，也是世界上现存最大、保存最为完整的木质结构古建筑群之一。\n【用户输入】\n现在我们来来测测试一下他他这这个用大大大模型型优化哈啊比较短的那一句一一段断你这个\n录录音大大大概需要多久久那现在的话大大概是十几秒左右左右左右左右\n【修正输出】\n现在我们来测试一下，用大模型优化较短的一段录音大概需要多久。现在的话，大概是十几秒左右。';
}
