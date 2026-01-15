import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/utils/logger.dart';
import '../models/story_model.dart';
import '../models/suspect_model.dart';

abstract class StoryLocalDataSource {
  Future<StoryModel> getOfflineStory(int suspectCount, String languageCode);
}

class StoryLocalDataSourceImpl implements StoryLocalDataSource {
  @override
  Future<StoryModel> getOfflineStory(
    int suspectCount,
    String languageCode,
  ) async {
    try {
      AppLogger.logInfo('Loading offline stories for language: $languageCode');

      final fileName = languageCode == 'en'
          ? 'assets/data/stories_offline_en.json'
          : 'assets/data/stories_offline.json';

      final jsonString = await rootBundle.loadString(fileName);
      AppLogger.logInfo('Loaded JSON string, length: ${jsonString.length}');

      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final storiesList = jsonData['stories'] as List;
      AppLogger.logInfo('Found ${storiesList.length} offline stories');

      if (storiesList.isEmpty) {
        throw Exception('error_no_offline_stories'.tr());
      }

      final random = Random();
      final storyIndex = random.nextInt(storiesList.length);
      AppLogger.logInfo('Selecting story #$storyIndex');

      final storyData = storiesList[storyIndex] as Map<String, dynamic>;
      final story = StoryModel.fromJson(storyData);
      AppLogger.logInfo('Offline story loaded: "${story.title}"');

      return _adaptStoryToPlayerCount(story, suspectCount);
    } catch (e, stackTrace) {
      AppLogger.logError('StoryLocalDataSource', e, stackTrace: stackTrace);
      ErrorHandler.logError(
        e,
        stackTrace: stackTrace,
        context: 'StoryLocalDataSource.getOfflineStory',
      );
      throw Exception('error_load_offline_stories'.tr() + ': ${e.toString()}');
    }
  }

  StoryModel _adaptStoryToPlayerCount(StoryModel story, int suspectCount) {
    if (story.suspects.length > suspectCount) {
      final random = Random();
      final shuffled = List.from(story.suspects)..shuffle(random);

      final killerSuspect = (story.suspects as List<SuspectModel>).firstWhere(
        (s) => s.name == story.killerName,
        orElse: () => story.suspects.first as SuspectModel,
      );

      final selectedSuspects = [killerSuspect];
      for (var suspect in shuffled) {
        if (suspect.name != killerSuspect.name &&
            selectedSuspects.length < suspectCount) {
          selectedSuspects.add(suspect);
        }
      }

      return StoryModel(
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
