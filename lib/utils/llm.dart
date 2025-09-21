import 'package:jiyi/src/rust/api.dart' as api;
import 'package:jiyi/src/rust/frb_generated.dart';
import 'package:jiyi/utils/data/llm_setting.dart';

abstract class Llm {
  static bool init = false;

  static String imagine(LLMSetting setting, String input) {
    if (!init) {
      RustLib.init();
    }
    return api.prompt(
      root: setting.rootPath,
      system: setting.imaginePrompt,
      prompt: input,
    );
  }
}
