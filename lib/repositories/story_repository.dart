import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import '../models/story.dart';
import '../services/gemini_service.dart';
import '../services/connectivity_service.dart';
import '../services/error_handler.dart';

class StoryRepository {
  final GeminiService _geminiService;
  final ConnectivityService _connectivityService;

  StoryRepository({
    required GeminiService geminiService,
    required ConnectivityService connectivityService,
  })  : _geminiService = geminiService,
        _connectivityService = connectivityService;

  Future<Story> getStory({
    required int suspectCount,
    required bool hasDetective,
  }) async {
    print('🎮 [StoryRepository] Starting story generation...');
    print('🎮 [StoryRepository] Suspect count: $suspectCount, Has detective: $hasDetective');
    
    // Web browsers have CORS restrictions that prevent direct API calls
    // Use offline stories for web platform
    if (kIsWeb) {
      print('🌐 [StoryRepository] Running on WEB platform - CORS will block API');
      ErrorHandler.logError('Running on web - using offline stories due to CORS restrictions', 
          context: 'StoryRepository.getStory');
      return await _getOfflineStory(suspectCount);
    }

    // Check connectivity for mobile/desktop platforms
    print('📡 [StoryRepository] Checking internet connectivity...');
    final isConnected = await _connectivityService.isConnected();
    print('📡 [StoryRepository] Internet connected: $isConnected');

    if (isConnected) {
      try {
        print('🤖 [StoryRepository] Attempting to call Gemini API...');
        // Try to generate story from Gemini API
        final story = await _geminiService.generateStory(
          suspectCount: suspectCount,
          hasDetective: hasDetective,
        );
        print('✅ [StoryRepository] SUCCESS! Got story from Gemini API: "${story.title}"');
        return _adaptStoryToPlayerCount(story, suspectCount);
      } catch (e) {
        print('❌ [StoryRepository] GEMINI API FAILED!');
        print('❌ [StoryRepository] Error type: ${e.runtimeType}');
        print('❌ [StoryRepository] Error message: $e');
        ErrorHandler.logError(e, context: 'StoryRepository.getStory - API failed, falling back to offline');
        // Fall back to offline stories if API fails
        return await _getOfflineStory(suspectCount);
      }
    } else {
      // No internet, use offline stories
      print('📵 [StoryRepository] No internet connection detected');
      ErrorHandler.logError('No internet connection', context: 'StoryRepository.getStory');
      return await _getOfflineStory(suspectCount);
    }
  }

  Future<Story> _getOfflineStory(int suspectCount) async {
    try {
      print('📚 [StoryRepository] Loading offline stories from assets...');
      // Load offline stories from assets
      final jsonString = await rootBundle.loadString('assets/data/stories_offline.json');
      print('📚 [StoryRepository] Loaded JSON string, length: ${jsonString.length}');
      
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final storiesList = jsonData['stories'] as List;
      print('📚 [StoryRepository] Found ${storiesList.length} offline stories');
      
      if (storiesList.isEmpty) {
        print('❌ [StoryRepository] No offline stories available!');
        throw Exception('مفيش قصص أوفلاين متاحة');
      }
      
      // Pick a random story
      final random = Random();
      final storyIndex = random.nextInt(storiesList.length);
      print('📚 [StoryRepository] Selecting story #$storyIndex');
      
      final storyData = storiesList[storyIndex] as Map<String, dynamic>;
      final story = Story.fromJson(storyData);
      print('✅ [StoryRepository] Offline story loaded: "${story.title}"');
      
      return _adaptStoryToPlayerCount(story, suspectCount);
    } catch (e, stackTrace) {
      print('❌ [StoryRepository] Failed to load offline story!');
      print('❌ [StoryRepository] Error: $e');
      print('❌ [StoryRepository] Stack trace: $stackTrace');
      ErrorHandler.logError(e, stackTrace: stackTrace, context: 'StoryRepository._getOfflineStory');
      throw Exception('فشل تحميل القصص الأوفلاين: ${e.toString()}');
    }
  }


  Story _adaptStoryToPlayerCount(Story story, int suspectCount) {
    // If the story has more suspects than needed, trim them
    if (story.suspects.length > suspectCount) {
      final random = Random();
      final shuffled = List<Suspect>.from(story.suspects)..shuffle(random);
      
      // Make sure the killer is included
      final killerSuspect = story.suspects.firstWhere(
        (s) => s.name == story.killerName,
        orElse: () => story.suspects.first,
      );
      
      final selectedSuspects = <Suspect>[killerSuspect];
      for (var suspect in shuffled) {
        if (suspect.name != killerSuspect.name && selectedSuspects.length < suspectCount) {
          selectedSuspects.add(suspect);
        }
      }
      
      return Story(
        title: story.title,
        intro: story.intro,
        crimeDescription: story.crimeDescription,
        suspects: selectedSuspects,
        clues: story.clues,
        twist: story.twist,
        killerName: story.killerName,
      );
    }
    
    return story;
  }
}
