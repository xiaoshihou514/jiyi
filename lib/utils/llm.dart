// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:jiyi/utils/anno.dart';
import 'package:jiyi/utils/data/llm_setting.dart';
import 'package:ollama_dart/ollama_dart.dart';

const _defaultModel = 'deepseek-v2:16b';
const _defaultBaseUrl = "http://127.0.0.1:11434/api";

abstract class Llm {
  static bool init = false;
  static final TRIM_PREFIX = ["\n", "\t", " ", "<think>", "</think>", "。", "，"];

  @DeepSeek()
  static String trim(String text) {
    if (text.isEmpty) {
      return text;
    }
    text = text.trim();

    // 去除开头的匹配模式
    int startIndex = 0;
    bool startFound = true;

    while (startFound && startIndex < text.length) {
      startFound = false;
      for (String pattern in TRIM_PREFIX) {
        if (pattern.isEmpty) continue;

        if (text.startsWith(pattern, startIndex)) {
          startIndex += pattern.length;
          startFound = true;
          break; // 找到一个匹配就跳出循环，重新检查
        }
      }
    }

    // 去除结尾的匹配模式
    int endIndex = text.length;
    bool endFound = true;

    while (endFound && endIndex > startIndex) {
      endFound = false;
      for (String pattern in TRIM_PREFIX) {
        if (pattern.isEmpty) continue;

        if (text.substring(0, endIndex).endsWith(pattern)) {
          endIndex -= pattern.length;
          endFound = true;
          break; // 找到一个匹配就跳出循环，重新检查
        }
      }
    }

    return text.substring(startIndex, endIndex);
  }

  static Future<String> prompt(String system, String prompt) async {
    final client = _createClient();
    try {
      print("start gen $prompt");
      final generated = await client.generateCompletion(
        request: GenerateCompletionRequest(
          model: _defaultModel,
          system: system,
          prompt: prompt,
        ),
      );
      print(generated.response);
      return generated.response ?? "";
    } finally {
      client.endSession();
    }
  }

  static Future<String> imagine(LLMSetting setting, String input) async =>
      prompt(setting.imaginePrompt, input);

  static Future<LlmChatResponse> chatWithJsonSchema({
    required String systemPrompt,
    required String userPrompt,
    required Map<String, dynamic> schema,
    String model = _defaultModel,
  }) async {
    final client = _createClient();
    print(userPrompt);
    try {
      final completion = await client.generateChatCompletion(
        request: GenerateChatCompletionRequest(
          model: model,
          messages: [
            Message(role: MessageRole.system, content: systemPrompt),
            Message(role: MessageRole.user, content: userPrompt),
          ],
          format: GenerateChatCompletionRequestFormat.schema(schema),
        ),
      );

      final content = completion.message.content;
      return LlmChatResponse(
        rawResponse: content,
        json: json.decode(content) as Map<String, dynamic>,
      );
    } finally {
      client.endSession();
    }
  }

  static Stream<String> streamChat({
    required String systemPrompt,
    required String userPrompt,
    String model = _defaultModel,
  }) async* {
    final client = _createClient();
    try {
      final stream = client.generateChatCompletionStream(
        request: GenerateChatCompletionRequest(
          model: model,
          keepAlive: 1,
          messages: [
            Message(role: MessageRole.system, content: systemPrompt),
            Message(role: MessageRole.user, content: userPrompt),
          ],
        ),
      );

      await for (final chunk in stream) {
        final content = chunk.message.content;
        if (content.isEmpty) continue;
        yield content;
      }
    } finally {
      client.endSession();
    }
  }

  static OllamaClient _createClient() => OllamaClient(baseUrl: _defaultBaseUrl);
}

class LlmChatResponse {
  final String? rawResponse;
  final Map<String, dynamic>? json;

  const LlmChatResponse({required this.rawResponse, required this.json});
}
