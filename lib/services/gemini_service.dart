import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/story.dart';
import 'error_handler.dart';

class GeminiService {
  final Dio _dio;
  final String apiKey;

  GeminiService({required this.apiKey})
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

  Future<Story> generateStory({
    required int suspectCount,
    required bool hasDetective,
  }) async {
    try {
      print('🤖 [GeminiService] Building prompt for $suspectCount suspects...');
      final prompt = _buildPrompt(suspectCount, hasDetective);
      print('🤖 [GeminiService] Prompt length: ${prompt.length} characters');

      print('🌐 [GeminiService] Sending request to Gemini API...');
      print(
        '🌐 [GeminiService] URL: ${_dio.options.baseUrl}/models/gemini-2.5-flash:generateContent',
      );
      print('🌐 [GeminiService] API Key: ${apiKey.substring(0, 10)}...');

      final response = await _dio.post(
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

      print('✅ [GeminiService] Got response! Status: ${response.statusCode}');

      // Validate response structure
      print('🔍 [GeminiService] Validating response structure...');
      if (response.data == null ||
          response.data['candidates'] == null ||
          response.data['candidates'].isEmpty) {
        print('❌ [GeminiService] Invalid response: No candidates');
        throw Exception('رد مش صحيح من الـ API: مفيش نتايج');
      }

      final candidate = response.data['candidates'][0];
      if (candidate['content'] == null ||
          candidate['content']['parts'] == null ||
          candidate['content']['parts'].isEmpty) {
        print('❌ [GeminiService] Invalid response: No content parts');
        throw Exception('رد مش صحيح من الـ API: مفيش محتوى');
      }

      final generatedText = candidate['content']['parts'][0]['text'] as String?;
      if (generatedText == null || generatedText.isEmpty) {
        print('❌ [GeminiService] Invalid response: Empty text');
        throw Exception('رد مش صحيح من الـ API: محتوى فاضي');
      }

      print(
        '📝 [GeminiService] Generated text length: ${generatedText.length} characters',
      );
      print(
        '📝 [GeminiService] First 200 chars: ${generatedText.substring(0, generatedText.length > 200 ? 200 : generatedText.length)}',
      );

      // Parse the JSON response from Gemini
      print('🔧 [GeminiService] Extracting JSON from response...');
      final storyJson = _extractJsonFromResponse(generatedText);
      print('✅ [GeminiService] JSON extracted successfully!');
      print('📖 [GeminiService] Story title: ${storyJson['title']}');

      return Story.fromJson(storyJson);
    } on DioException catch (e) {
      print('❌ [GeminiService] DioException caught!');
      print('❌ [GeminiService] Exception type: ${e.type}');
      print('❌ [GeminiService] Message: ${e.message}');
      print('❌ [GeminiService] Response: ${e.response?.data}');
      print('❌ [GeminiService] Status code: ${e.response?.statusCode}');

      ErrorHandler.logError(e, context: 'GeminiService.generateStory');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        print('⏱️ [GeminiService] Timeout error');
        throw Exception('الطلب خد وقت كتير. حاول تاني.');
      } else if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        print('🚫 [GeminiService] Bad response with status: $statusCode');
        if (statusCode == 401 || statusCode == 403) {
          print('🔑 [GeminiService] Authentication failed - check API key');
          throw Exception('المصادقة فشلت. اتأكد من الـ API key.');
        } else if (statusCode != null && statusCode >= 500) {
          print('🔥 [GeminiService] Server error');
          throw Exception('خطأ في السيرفر. حاول بعدين.');
        } else {
          print('❓ [GeminiService] Unknown bad response');
          throw Exception('طلب الـ API فشل بكود $statusCode');
        }
      } else if (e.type == DioExceptionType.connectionError) {
        print(
          '📵 [GeminiService] Connection error - likely CORS or network issue',
        );
        throw Exception('مفيش نت. اتأكد من النت.');
      } else {
        print('❓ [GeminiService] Unknown DioException type');
        throw Exception('فشل توليد القصة: ${e.message ?? 'خطأ مجهول'}');
      }
    } on FormatException catch (e) {
      print('❌ [GeminiService] FormatException: JSON parsing failed');
      print('❌ [GeminiService] Error: $e');
      ErrorHandler.logError(e, context: 'GeminiService.generateStory');
      throw Exception('فشل قراية القصة: صيغة JSON غلط');
    } catch (e) {
      print('❌ [GeminiService] Unexpected error: ${e.runtimeType}');
      print('❌ [GeminiService] Error: $e');
      ErrorHandler.logError(e, context: 'GeminiService.generateStory');
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
    // Remove markdown code blocks if present
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
      // Try to find JSON object in the response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
      if (jsonMatch != null) {
        return json.decode(jsonMatch.group(0)!) as Map<String, dynamic>;
      }
      rethrow;
    }
  }
}
