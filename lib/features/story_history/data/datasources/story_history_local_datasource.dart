import 'package:hive_ce/hive.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/played_story.dart';
import '../models/played_story_model.dart';

abstract class StoryHistoryLocalDataSource {
  Future<List<PlayedStory>> getSavedStories();
  Future<void> savePlayedStory(PlayedStory story);
  Future<void> deleteStory(String id);
  Future<void> rateStory(String id, int rating);
  Future<List<PlayedStory>> getPendingUploads();
  Future<void> markAsUploaded(String id);
}

class StoryHistoryLocalDataSourceImpl implements StoryHistoryLocalDataSource {
  static const String boxName = 'story_history_box';
  static const int maxStories = 50;

  Future<Box<PlayedStoryModel>> _getBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      return Hive.openBox<PlayedStoryModel>(boxName);
    }
    return Hive.box<PlayedStoryModel>(boxName);
  }

  @override
  Future<List<PlayedStory>> getSavedStories() async {
    final box = await _getBox();
    final models = box.values.toList();
    models.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> savePlayedStory(PlayedStory story) async {
    final box = await _getBox();
    final model = PlayedStoryModel.fromEntity(story);
    final existing = box.get(model.id);
    AppLogger.logInfo(
      'StoryHistoryLocalDataSource: save id=${model.id} existing=${existing != null} rating=${story.userRating} uploaded=${story.isUploaded}',
    );
    if (existing != null) {
      final merged = PlayedStoryModel(
        id: existing.id,
        storyJson: existing.storyJson,
        // Keep latest replay time for sorting while preserving other user data.
        playedAt: model.playedAt.isAfter(existing.playedAt)
            ? model.playedAt
            : existing.playedAt,
        userRating: existing.userRating ?? model.userRating,
        isUploaded: existing.isUploaded || model.isUploaded,
      );
      await box.put(merged.id, merged);
      AppLogger.logInfo(
        'StoryHistoryLocalDataSource: merged existing id=${merged.id} rating=${merged.userRating} uploaded=${merged.isUploaded}',
      );
    } else {
      await box.put(model.id, model);
      AppLogger.logInfo(
        'StoryHistoryLocalDataSource: inserted new id=${model.id}',
      );
    }

    // Enforce FIFO max-50 cap
    if (box.length > maxStories) {
      final sorted = box.values.toList()
        ..sort((a, b) => a.playedAt.compareTo(b.playedAt));
      final toDelete = sorted.take(box.length - maxStories).map((m) => m.id);
      await box.deleteAll(toDelete);
    }
  }

  @override
  Future<void> deleteStory(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  @override
  Future<void> rateStory(String id, int rating) async {
    final box = await _getBox();
    final model = box.get(id);
    if (model != null) {
      await box.put(id, model.copyWith(userRating: rating));
      AppLogger.logInfo(
        'StoryHistoryLocalDataSource: rating set id=$id rating=$rating',
      );
    } else {
      AppLogger.logInfo(
        'StoryHistoryLocalDataSource: rate ignored, missing id=$id',
      );
    }
  }

  @override
  Future<List<PlayedStory>> getPendingUploads() async {
    final box = await _getBox();
    final all = box.values.toList();
    final ratedAndNotUploaded = all
        .where((m) => m.userRating != null && !m.isUploaded)
        .toList();
    final unratedAndNotUploaded = all
        .where((m) => m.userRating == null && !m.isUploaded)
        .toList();
    final alreadyUploaded = all.where((m) => m.isUploaded).toList();
    AppLogger.logInfo(
      'StoryHistoryLocalDataSource: pending scan total=${all.length} pendingRated=${ratedAndNotUploaded.length} pendingUnrated=${unratedAndNotUploaded.length} uploaded=${alreadyUploaded.length}',
    );
    return ratedAndNotUploaded.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> markAsUploaded(String id) async {
    final box = await _getBox();
    final model = box.get(id);
    if (model != null) {
      await box.put(id, model.copyWith(isUploaded: true));
      AppLogger.logInfo(
        'StoryHistoryLocalDataSource: markAsUploaded success id=$id',
      );
    } else {
      AppLogger.logInfo(
        'StoryHistoryLocalDataSource: markAsUploaded ignored, missing id=$id',
      );
    }
  }
}
