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
}
