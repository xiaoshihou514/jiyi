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
  String get settings_map_saved => 'Map settings saved';

  @override
  String get settings_map_reset => 'Map settings reset';

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
  String get settings_asr_provider => 'Select speech recognition model';

  @override
  String get settings_asr_custom => 'Local speech recognition model';

  @override
  String get settings_asr_saved => 'ASR settings saved';

  @override
  String get settings_asr_reset => 'Speech recognition settings reset';

  @override
  String get settings_asr_single => 'Single model path (for Ctc series models)';

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
  String get settings_asr_missing_fields =>
      'Speech recognition configuration incomplete';

  @override
  String get settings_asr_zh_en_streaming_zipformer =>
      'Chinese-English bilingual recognition (~500M)';

  @override
  String get settings_asr_zh_en_streaming_paraformer =>
      'Chinese-English bilingual recognition (~1G)';

  @override
  String get settings_asr_zh_streaming_ctc => 'Chinese recognition (~700M)';

  @override
  String get settings_asr_en_nemo_ctc => 'English recognition (~50M)';

  @override
  String get settings_zdpp_custom => 'Local typesetting model';

  @override
  String get settings_zdpp_zh_en => 'Chinese-English typesetting model';

  @override
  String get settings_zdpp_zh_en_int8 =>
      'Chinese-English typesetting model (int8)';

  @override
  String get settings_zdpp_model => 'Automatic typesetting settings';

  @override
  String get settings_zdpp_missing_fields =>
      'Automatic typesetting configuration incomplete';

  @override
  String get settings_zdpp_saved => 'Automatic typesetting settings saved';

  @override
  String get settings_zdpp_reset => 'Automatic typesetting settings reset';

  @override
  String get settings_zdpp_provider => 'Select automatic typesetting model';

  @override
  String get settings_zdpp_path => 'Model path';

  @override
  String get settings_zdpp_download_desc =>
      'Please download models from sherpa-onnx yourself, or use pre-configured options if you prefer convenience';

  @override
  String get settings_zdpp_download_exp =>
      'sherpa-onnx only provides three models in total, handle as you see fit';

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
  String get metadata_edit_title => 'Edit metadata';

  @override
  String get metadata_save => 'Save';

  @override
  String get metadata_transcript_label => 'Transcription text';

  @override
  String get metadata_transcript_hint => 'Enter audio transcription text';

  @override
  String get metadata_zdpp => 'Automatic typesetting';

  @override
  String get metadata_rebuild_transcript => 'Re-recognize speech';

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
  String get transcript_empty => 'No text recognized';

  @override
  String get missing_map_settings =>
      'Map source not configured, geographic view unavailable';

  @override
  String get missing_asr_settings =>
      'Transcription model not configured, speech-to-text unavailable';

  @override
  String get missing_zdpp_settings =>
      'Automatic typesetting model not configured, automatic typesetting unavailable';

  @override
  String get geo_lookup_missing_coords =>
      'Unable to query location: missing latitude/longitude information';

  @override
  String get geo_lookup_success => 'Location information queried';

  @override
  String get geo_lookup_failed => 'Failed to query location information';

  @override
  String get metadata_saved => 'Saved';

  @override
  String metadata_location_display(Object geodesc) {
    return 'Location: $geodesc';
  }

  @override
  String get metadata_location_unset => 'Not set';

  @override
  String get settings_geo => 'Coordinate Parsing Settings';

  @override
  String get settings_geo_desc =>
      'Download geographic data files to support location query functionality';

  @override
  String get settings_geo_download => 'Download geographic data';

  @override
  String get settings_geo_saved => 'Coordinate parsing settings saved';

  @override
  String get settings_geo_reset => 'Coordinate parsing settings reset';

  @override
  String get settings_geo_bulk_generate => 'Bulk Generate Locations';

  @override
  String get settings_geo_bulk_generate_title =>
      'Bulk Generate Location Information';

  @override
  String settings_geo_bulk_generate_message(int count) {
    return 'Found $count recordings with coordinates but no location information. Generate location info for them?';
  }

  @override
  String get settings_geo_bulk_cancel => 'Cancel';

  @override
  String get settings_geo_bulk_confirm => 'Confirm';

  @override
  String get settings_geo_bulk_processing => 'Processing...';

  @override
  String settings_geo_bulk_complete(int success, int total) {
    return 'Completed: $success succeeded out of $total';
  }

  @override
  String get settings_geo_bulk_no_recordings =>
      'No recordings need location information';

  @override
  String get geo_timeline_title => 'Geographic Timeline';

  @override
  String get geo_timeline_empty => 'No recordings with geolocation';

  @override
  String geo_timeline_recording_count(int count) {
    return '$count recordings';
  }

  @override
  String get geo_timeline_notable => 'Notable Recordings';

  @override
  String get geo_spatial_title => 'Geographic Statistics';

  @override
  String get geo_spatial_empty => 'No recordings with geolocation';
}
