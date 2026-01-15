import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/utils/logger.dart';
import '../models/story_model.dart';

abstract class StoryRemoteDataSource {
  Future<StoryModel> generateStory({
    required int suspectCount,
    required bool hasDetective,
  });
}

class StoryRemoteDataSourceImpl implements StoryRemoteDataSource {
  final Dio dio;
  final String apiKey;

  StoryRemoteDataSourceImpl({
    required this.dio,
    required this.apiKey,
  });

  @override
  Future<StoryModel> generateStory({
    required int suspectCount,
    required bool hasDetective,
  }) async {
    try {
      AppLogger.logApiCall('Gemini API - generateStory', params: {
        'suspectCount': suspectCount,
        'hasDetective': hasDetective,
      });

      final prompt = _buildPrompt(suspectCount, hasDetective);
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
        throw Exception('رد مش صحيح من الـ API: مفيش نتايج');
      }

      final candidate = response.data['candidates'][0];
      if (candidate['content'] == null ||
          candidate['content']['parts'] == null ||
          candidate['content']['parts'].isEmpty) {
        throw Exception('رد مش صحيح من الـ API: مفيش محتوى');
      }

      final generatedText = candidate['content']['parts'][0]['text'] as String?;
      if (generatedText == null || generatedText.isEmpty) {
        throw Exception('رد مش صحيح من الـ API: محتوى فاضي');
      }

      final storyJson = _extractJsonFromResponse(generatedText);
      return StoryModel.fromJson(storyJson);
    } on DioException catch (e) {
      AppLogger.logError('StoryRemoteDataSource', e);
      ErrorHandler.logError(e, context: 'StoryRemoteDataSource.generateStory');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('الطلب خد وقت كتير. حاول تاني.');
      } else if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          throw Exception('المصادقة فشلت. اتأكد من الـ API key.');
        } else if (statusCode != null && statusCode >= 500) {
          throw Exception('خطأ في السيرفر. حاول بعدين.');
        } else {
          throw Exception('طلب الـ API فشل بكود $statusCode');
        }
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('مفيش نت. اتأكد من النت.');
      } else {
        throw Exception('فشل توليد القصة: ${e.message ?? 'خطأ مجهول'}');
      }
    } on FormatException catch (e) {
      AppLogger.logError('StoryRemoteDataSource', e);
      ErrorHandler.logError(e, context: 'StoryRemoteDataSource.generateStory');
      throw Exception('فشل قراية القصة: صيغة JSON غلط');
    } catch (e) {
      AppLogger.logError('StoryRemoteDataSource', e);
      ErrorHandler.logError(e, context: 'StoryRemoteDataSource.generateStory');
      rethrow;
    }
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
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
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
