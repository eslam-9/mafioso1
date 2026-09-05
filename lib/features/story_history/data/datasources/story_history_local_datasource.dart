import 'package:hive_ce/hive.dart';
import '../../domain/entities/played_story.dart';
import '../models/played_story_model.dart';

abstract class StoryHistoryLocalDataSource {
  Future<List<PlayedStory>> getSavedStories();
  Future<void> savePlayedStory(PlayedStory story);
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
    await box.put(model.id, model);

    // Enforce FIFO max-50 cap
    if (box.length > maxStories) {
      final sorted = box.values.toList()
        ..sort((a, b) => a.playedAt.compareTo(b.playedAt));
      final toDelete = sorted.take(box.length - maxStories).map((m) => m.id);
      await box.deleteAll(toDelete);
    }
  }

  @override
  Future<void> rateStory(String id, int rating) async {
    final box = await _getBox();
    final model = box.get(id);
    if (model != null) {
      await box.put(id, model.copyWith(userRating: rating));
    }
  }

  @override
  Future<List<PlayedStory>> getPendingUploads() async {
    final box = await _getBox();
    return box.values
        .where((m) => m.userRating != null && !m.isUploaded)
        .map((m) => m.toEntity())
        .toList();
  }

  @override
  Future<void> markAsUploaded(String id) async {
    final box = await _getBox();
    final model = box.get(id);
    if (model != null) {
      await box.put(id, model.copyWith(isUploaded: true));
    }
  }
}
