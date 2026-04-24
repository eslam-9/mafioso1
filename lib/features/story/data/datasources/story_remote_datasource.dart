import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/ai_provider/ai_provider.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/utils/logger.dart';
import '../models/story_model.dart';

abstract class StoryRemoteDataSource {
  Future<StoryModel> generateStory({
    required int suspectCount,
    required bool hasDetective,
    required String languageCode,
    required AiProvider aiProvider,
  });
}

class StoryRemoteDataSourceImpl implements StoryRemoteDataSource {
  final Dio geminiDio;
  final Dio groqDio;
  final String geminiApiKey;
  final String groqApiKey;

  StoryRemoteDataSourceImpl({
    required this.geminiDio,
    required this.groqDio,
    required this.geminiApiKey,
    required this.groqApiKey,
  });

  @override
  Future<StoryModel> generateStory({
    required int suspectCount,
    required bool hasDetective,
    required String languageCode,
    required AiProvider aiProvider,
  }) async {
    if (aiProvider == AiProvider.groq) {
      return _generateWithGroq(
        suspectCount: suspectCount,
        hasDetective: hasDetective,
        languageCode: languageCode,
      );
    }
    return _generateWithGemini(
      suspectCount: suspectCount,
      hasDetective: hasDetective,
      languageCode: languageCode,
    );
  }

  Future<StoryModel> _generateWithGemini({
    required int suspectCount,
    required bool hasDetective,
    required String languageCode,
  }) async {
    try {
      AppLogger.logApiCall(
        'Gemini API - generateStory',
        params: {
          'suspectCount': suspectCount,
          'hasDetective': hasDetective,
          'languageCode': languageCode,
        },
      );

      final prompt = languageCode == 'en'
          ? _buildEnglishPrompt(suspectCount, hasDetective)
          : _buildPrompt(suspectCount, hasDetective);

      AppLogger.logInfo('Prompt length: ${prompt.length} characters');

      final response = await geminiDio.post(
        '/models/gemini-2.5-flash:generateContent',
        queryParameters: {'key': geminiApiKey},
        data: {
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 1.0,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 8192,
            'responseMimeType': 'application/json',
            'responseSchema': {
              'type': 'object',
              'properties': {
                'title': {'type': 'string'},
                'intro': {'type': 'string'},
                'crimeDescription': {'type': 'string'},
                'suspects': {
                  'type': 'array',
                  'items': {
                    'type': 'object',
                    'properties': {
                      'name': {'type': 'string'},
                      'suspiciousBehavior': {'type': 'string'},
                    },
                    'required': ['name', 'suspiciousBehavior'],
                  },
                },
                'clues': {
                  'type': 'array',
                  'items': {
                    'type': 'object',
                    'properties': {
                      'text': {'type': 'string'},
                      'difficulty': {
                        'type': 'string',
                        'enum': [
                          'veryEasy',
                          'easy',
                          'medium',
                          'hard',
                          'veryHard',
                        ],
                      },
                    },
                    'required': ['text', 'difficulty'],
                  },
                },
                'twist': {'type': 'string'},
                'killerName': {'type': 'string'},
              },
              'required': [
                'title',
                'intro',
                'crimeDescription',
                'suspects',
                'clues',
                'twist',
                'killerName',
              ],
            },
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_ONLY_HIGH',
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_ONLY_HIGH',
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_ONLY_HIGH',
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_ONLY_HIGH',
            },
          ],
        },
      );

      AppLogger.logInfo('API response status: ${response.statusCode}');

      if (response.data == null ||
          response.data['candidates'] == null ||
          response.data['candidates'].isEmpty) {
        final blockReason = response.data?['promptFeedback']?['blockReason'];
        AppLogger.logError(
          'StoryRemoteDataSource',
          'No candidates returned. blockReason: $blockReason | Full response: ${response.data}',
        );
        throw Exception('API error: No results (blockReason: $blockReason)');
      }

      final candidate = response.data['candidates'][0];
      final finishReason = candidate['finishReason'] as String? ?? 'UNKNOWN';
      AppLogger.logInfo('Candidate finishReason: $finishReason');

      if (candidate['content'] == null ||
          candidate['content']['parts'] == null ||
          candidate['content']['parts'].isEmpty) {
        final safetyRatings = candidate['safetyRatings'];
        AppLogger.logError(
          'StoryRemoteDataSource',
          'No content in candidate. finishReason: $finishReason, safetyRatings: $safetyRatings',
        );
        throw Exception('API error: No content (finishReason: $finishReason)');
      }

      final generatedText = candidate['content']['parts'][0]['text'] as String?;
      if (generatedText == null || generatedText.isEmpty) {
        throw Exception('API error: Empty content');
      }

      final storyJson = _extractJsonFromResponse(generatedText);
      return StoryModel.fromJson(storyJson);
    } on DioException catch (e) {
      AppLogger.logError('StoryRemoteDataSource', e);
      if (e.response?.data != null) {
        AppLogger.logError(
          'StoryRemoteDataSource',
          'API response body: ${e.response?.data}',
        );
      }
      ErrorHandler.logError(e, context: 'StoryRemoteDataSource.generateStory');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('timeout'.tr());
      } else if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          throw Exception('error_auth_failed'.tr());
        } else if (statusCode != null && statusCode >= 500) {
          throw Exception('error_server_error'.tr());
        } else {
          throw Exception(
            'error_api_failed_code'.tr(
              namedArgs: {'code': statusCode.toString()},
            ),
          );
        }
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('error_no_internet'.tr());
      } else {
        throw Exception('error_generation_failed'.tr());
      }
    } on FormatException catch (e) {
      AppLogger.logError('StoryRemoteDataSource', e);
      ErrorHandler.logError(e, context: 'StoryRemoteDataSource.generateStory');
      throw Exception('error_invalid_json'.tr());
    } catch (e) {
      AppLogger.logError('StoryRemoteDataSource', e);
      ErrorHandler.logError(e, context: 'StoryRemoteDataSource.generateStory');
      rethrow;
    }
  }

  Future<StoryModel> _generateWithGroq({
    required int suspectCount,
    required bool hasDetective,
    required String languageCode,
  }) async {
    try {
      AppLogger.logApiCall(
        'Groq API - generateStory',
        params: {
          'suspectCount': suspectCount,
          'hasDetective': hasDetective,
          'languageCode': languageCode,
        },
      );

      final prompt = languageCode == 'en'
          ? _buildEnglishPrompt(suspectCount, hasDetective)
          : _buildPrompt(suspectCount, hasDetective);

      AppLogger.logInfo('Prompt length: ${prompt.length} characters');

      final response = await groqDio.post(
        '/chat/completions',
        options: Options(headers: {'Authorization': 'Bearer $groqApiKey'}),
        data: {
          'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 8192,
          'temperature': 1.0,
          'response_format': {'type': 'json_object'},
        },
      );

      AppLogger.logInfo('API response status: ${response.statusCode}');

      if (response.data == null ||
          response.data['choices'] == null ||
          response.data['choices'].isEmpty) {
        throw Exception('API error: No results from Groq');
      }

      final choice = response.data['choices'][0];
      final finishReason = choice['finish_reason'] as String? ?? 'UNKNOWN';
      AppLogger.logInfo('Choice finishReason: $finishReason');

      if (choice['message'] == null || choice['message']['content'] == null) {
        throw Exception('API error: No content from Groq');
      }

      final generatedText = choice['message']['content'] as String?;
      if (generatedText == null || generatedText.isEmpty) {
        throw Exception('API error: Empty content');
      }

      final storyJson = _extractJsonFromResponse(generatedText);
      return StoryModel.fromJson(storyJson);
    } on DioException catch (e) {
      AppLogger.logError('StoryRemoteDataSource (Groq)', e);
      ErrorHandler.logError(
        e,
        context: 'StoryRemoteDataSource.generateStory (Groq)',
      );

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('timeout'.tr());
      } else if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          throw Exception('error_auth_failed'.tr());
        } else if (statusCode != null && statusCode >= 500) {
          throw Exception('error_server_error'.tr());
        } else {
          throw Exception(
            'error_api_failed_code'.tr(
              namedArgs: {'code': statusCode.toString()},
            ),
          );
        }
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('error_no_internet'.tr());
      } else {
        throw Exception('error_generation_failed'.tr());
      }
    } on FormatException catch (e) {
      AppLogger.logError('StoryRemoteDataSource (Groq)', e);
      ErrorHandler.logError(
        e,
        context: 'StoryRemoteDataSource.generateStory (Groq)',
      );
      throw Exception('error_invalid_json'.tr());
    } catch (e) {
      AppLogger.logError('StoryRemoteDataSource (Groq)', e);
      ErrorHandler.logError(
        e,
        context: 'StoryRemoteDataSource.generateStory (Groq)',
      );
      rethrow;
    }
  }

  String _buildEnglishPrompt(int suspectCount, bool hasDetective) {
    return '''
You are a professional detective puzzle designer.

Generate a SMART and LOGICAL murder mystery story.

CRITICAL RULES:
1. Write EVERYTHING in English.
2. Number of suspects: EXACTLY $suspectCount suspects.
3. Return ONLY valid JSON. No explanation, no text before or after.
4. DO NOT add comments inside JSON.
5. DO NOT leave trailing commas.
6. You MUST close all brackets correctly.
7. The response MUST start with { and end with }.

STORY RULES (IMPORTANT):
- The mystery must be solvable using the clues.
- Include a misleading element (red herring).
- The real cause of death must NOT be obvious.
- Use a hidden mechanism (habit / object / trick).
- The twist must be logical and based on clues.

JSON format (STRICT — DO NOT CHANGE KEYS OR STRUCTURE):

{
  "title": "Story Title",
  "intro": "Short intro (2-3 sentences)",
  "crimeDescription": "Detailed crime scene description (2-3 sentences)",
  "suspects": [
    {
      "name": "Suspect Name",
      "suspiciousBehavior": "Why they are suspicious"
    }
  ],
  "clues": [
    {"text": "Clue 1", "difficulty": "veryEasy"},
    {"text": "Clue 2", "difficulty": "easy"},
    {"text": "Clue 3", "difficulty": "medium"},
    {"text": "Clue 4", "difficulty": "hard"},
    {"text": "Clue 5", "difficulty": "veryHard"}
  ],
  "twist": "Logical explanation of what really happened",
  "killerName": "Exact Name of One Suspect"
}

STRICT REQUIREMENTS:
- EXACTLY $suspectCount suspects (no more, no less)
- EXACTLY 5 clues
- killerName MUST match one suspect EXACTLY
- NO extra fields
- NO missing fields
- NO invalid JSON

FINAL CHECK BEFORE OUTPUT:
- Ensure valid JSON
- Ensure all brackets are closed
- Ensure structure matches exactly

Return ONLY JSON.
''';
  }

  String _buildPrompt(int suspectCount, bool hasDetective) {
    return '''
إنت مصمم ألغاز جرايم محترف.

اكتب قصة جريمة ذكية بالمصري تتحل بالمنطق.

CRITICAL RULES:
1. كل الكلام بالمصري فقط (مش فصحى ومش إنجليزي)
2. عدد المشتبه فيهم: EXACTLY $suspectCount
3. رجّع JSON بس من غير أي كلام
4. ممنوع تحط comments جوه JSON
5. ممنوع trailing commas
6. لازم تقفل كل الأقواس صح
7. الرد لازم يبدأ بـ { وينتهي بـ }
8. DO NOT TRANSLATE JSON KEYS. Keep the exact english keys unchanged.

قواعد القصة:
- لازم يكون في تمويه (حاجة تضلل القارئ)
- طريقة القتل تكون غير مباشرة وذكية
- الحل لازم يعتمد على الأدلة
- في حاجة مخفية (عادة / أداة / حركة)

JSON format (STRICT — DO NOT TRANSLATE KEYS):

{
  "title": "عنوان القصة",
  "intro": "مقدمة قصيرة (جملتين أو تلاتة)",
  "crimeDescription": "وصف الجريمة (٢-٣ جمل)",
  "suspects": [
    {
      "name": "اسم شخص",
      "suspiciousBehavior": "ليه مشكوك فيه"
    }
  ],
  "clues": [
    {"text": "دليل", "difficulty": "veryEasy"},
    {"text": "دليل", "difficulty": "easy"},
    {"text": "دليل", "difficulty": "medium"},
    {"text": "دليل", "difficulty": "hard"},
    {"text": "دليل", "difficulty": "veryHard"}
  ],
  "twist": "شرح منطقي للحقيقة",
  "killerName": "اسم القاتل"
}

STRICT REQUIREMENTS:
- بالظبط $suspectCount مشتبه فيهم
- 5 clues بس
- القاتل لازم يكون واحد من اللي فوق
- مفيش fields زيادة أو ناقصة

FINAL CHECK:
- اتأكد إن JSON سليم
- كل الأقواس مقفولة
- نفس الشكل بالظبط

رجّع JSON بس
''';
  }

  Map<String, dynamic> _extractJsonFromResponse(String response) {
    String cleaned = response.trim();

    if (cleaned.startsWith('\uFEFF')) {
      cleaned = cleaned.substring(1);
    }

    final codeFencePattern = RegExp(r'^```[a-zA-Z]*\s*', multiLine: false);
    cleaned = cleaned.replaceFirst(codeFencePattern, '');
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }

    cleaned = cleaned.trim();

    try {
      return json.decode(cleaned) as Map<String, dynamic>;
    } catch (_) {}

    final firstBrace = cleaned.indexOf('{');
    final lastBrace = cleaned.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      final jsonCandidate = cleaned.substring(firstBrace, lastBrace + 1);
      try {
        return json.decode(jsonCandidate) as Map<String, dynamic>;
      } catch (e) {
        AppLogger.logError(
          'StoryRemoteDataSource._extractJsonFromResponse',
          'JSON candidate (strategy 2) failed: $e\nCandidate: ${jsonCandidate.substring(0, jsonCandidate.length.clamp(0, 300))}',
        );
      }
    }

    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
    if (jsonMatch != null) {
      try {
        return json.decode(jsonMatch.group(0)!) as Map<String, dynamic>;
      } catch (e) {
        AppLogger.logError(
          'StoryRemoteDataSource._extractJsonFromResponse',
          'Regex strategy failed: $e\nFull cleaned response: $cleaned',
        );
        throw FormatException('Failed to parse JSON from response: $e');
      }
    }

    AppLogger.logError(
      'StoryRemoteDataSource._extractJsonFromResponse',
      'No JSON object found in response. Full response: $cleaned',
    );
    throw const FormatException('No JSON object found in API response');
  }
}
