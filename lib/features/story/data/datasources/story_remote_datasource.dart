import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/utils/logger.dart';
import '../models/story_model.dart';

abstract class StoryRemoteDataSource {
  Future<StoryModel> generateStory({
    required int suspectCount,
    required bool hasDetective,
    required String languageCode,
  });
}

class StoryRemoteDataSourceImpl implements StoryRemoteDataSource {
  final Dio dio;
  final String apiKey;

  StoryRemoteDataSourceImpl({required this.dio, required this.apiKey});

  @override
  Future<StoryModel> generateStory({
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

      final response = await dio.post(
        '/models/gemini-2.5-flash:generateContent',
        queryParameters: {'key': apiKey},
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
            'maxOutputTokens': 3000,
            'candidateCount': 1,
          },
          'safetySettings': [
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
        throw Exception('API error: No results');
      }

      final candidate = response.data['candidates'][0];
      if (candidate['content'] == null ||
          candidate['content']['parts'] == null ||
          candidate['content']['parts'].isEmpty) {
        throw Exception('API error: No content');
      }

      final generatedText = candidate['content']['parts'][0]['text'] as String?;
      if (generatedText == null || generatedText.isEmpty) {
        throw Exception('API error: Empty content');
      }

      final storyJson = _extractJsonFromResponse(generatedText);
      return StoryModel.fromJson(storyJson);
    } on DioException catch (e) {
      AppLogger.logError('StoryRemoteDataSource', e);
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

  String _buildEnglishPrompt(int suspectCount, bool hasDetective) {
    return '''
You are a creative writer. Generate a murder mystery story in English.

CRITICAL RULES:
1. Write EVERYTHING in English.
2. Number of suspects: EXACTLY $suspectCount suspects
3. Return ONLY valid JSON, no extra text

JSON format:

{
  "title": "Story Title",
  "intro": "Short intro (2-3 sentences)",
  "crimeDescription": "Detailed crime scene description (3-4 sentences)",
  "suspects": [
    {
      "name": "Suspect Name",
      "suspiciousBehavior": "Why they are suspicious"
    }
    // Add exactly $suspectCount suspects in total
  ],
  "clues": [
    {"text": "Clue 1", "difficulty": "veryEasy"},
    {"text": "Clue 2", "difficulty": "easy"},
    {"text": "Clue 3", "difficulty": "medium"},
    {"text": "Clue 4", "difficulty": "hard"},
    {"text": "Clue 5", "difficulty": "veryHard"}
  ],
  "twist": "The plot twist explanation",
  "killerName": "Exact Name of One Suspect"
}

Requirements:
- Exactly $suspectCount suspects
- Exactly 5 clues with difficulties: veryEasy, easy, medium, hard, veryHard
- killerName must match one suspect's name exactly
- Return only the JSON, nothing else
''';
  }

  String _buildPrompt(int suspectCount, bool hasDetective) {
    return '''
You are a creative writer. Generate a murder mystery story in Egyptian Arabic dialect (العامية المصرية).

CRITICAL RULES:
1. Write EVERYTHING in Egyptian colloquial Arabic (not formal Arabic, not English)
2. Use Egyptian words like: لقينا، شفنا، كان قاعد، راح، جه، اتقتل، الحتة، بليل، عايز، ياخد، طلع، واقف، قدام
3. Number of suspects: EXACTLY $suspectCount suspects
4. Return ONLY valid JSON, no extra text

JSON format:

{
  "title": "عنوان القصة بالمصري (مثال: جريمة الفيلا المهجورة)",
  "intro": "مقدمة قصيرة بالمصري (جملتين أو تلاتة) - مثال: الليلة دي كانت غريبة في الحتة. حد اتقتل والكل بيقول إنه كان راجل كويس.",
  "crimeDescription": "وصف مفصل بالمصري لمشهد الجريمة واللي حصل (٣ أو ٤ جمل) - استخدم كلمات زي: لقوه، كان قاعد، الباب كان مفتوح، إلخ",
  "suspects": [
    {
      "name": "أحمد الشربيني",
      "suspiciousBehavior": "كان واقف قدام البيت بليل وشكله مش طبيعي"
    }
    // Add exactly $suspectCount more suspects with Egyptian names
  ],
  "clues": [
    {"text": "لقينا أثر جزمة غريبة جنب الباب", "difficulty": "veryEasy"},
    {"text": "الجيران سمعوا صوت خناقة بليل", "difficulty": "easy"},
    {"text": "في حد شاف عربية سودا واقفة بره", "difficulty": "medium"},
    {"text": "لقينا ورقة مكتوب عليها رقم تليفون", "difficulty": "hard"},
    {"text": "الكاميرا صورت حد داخل الساعة ١٠", "difficulty": "veryHard"}
  ],
  "twist": "طلع إن القاتل كان صاحبه من زمان",
  "killerName": "أحمد الشربيني"
}

Requirements:
- Exactly $suspectCount suspects with Egyptian names
- Exactly 5 clues with difficulties: veryEasy, easy, medium, hard, veryHard
- killerName must match one suspect's name exactly
- All text in Egyptian Arabic dialect
- Return only the JSON, nothing else
''';
  }

  Map<String, dynamic> _extractJsonFromResponse(String response) {
    String cleaned = response.trim();

    // Remove starting ```json or ```
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }

    // Remove ending ```
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }

    cleaned = cleaned.trim();

    try {
      return json.decode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
      if (jsonMatch != null) {
        return json.decode(jsonMatch.group(0)!) as Map<String, dynamic>;
      }
      rethrow;
    }
  }
}
