import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../features/story_history/domain/usecases/get_pending_uploads_usecase.dart';
import '../../features/story_history/domain/usecases/mark_as_uploaded_usecase.dart';
import '../../features/story_library/domain/usecases/upload_story_usecase.dart';
import '../../features/story_library/domain/usecases/rate_community_story_usecase.dart';
import '../../features/story_history/domain/entities/played_story.dart';
import '../../core/services/device_id_service.dart';
import '../../features/story/data/models/story_model.dart';
import '../../features/story/data/models/clue_model.dart';
import '../../features/story/data/models/suspect_model.dart';

/// Runs on startup and when connectivity is restored to retry any pending
/// story uploads + rating submissions that failed while the device was offline.
class UploadQueueService {
  final GetPendingUploadsUseCase getPendingUploads;
  final MarkAsUploadedUseCase markAsUploaded;
  final UploadStoryUseCase uploadStory;
  final RateCommunityStoryUseCase rateCommunityStory;
  final DeviceIdService deviceIdService;
  final Connectivity connectivity;

  UploadQueueService({
    required this.getPendingUploads,
    required this.markAsUploaded,
    required this.uploadStory,
    required this.rateCommunityStory,
    required this.deviceIdService,
    required this.connectivity,
  });

  /// Starts listening for connectivity changes and flushes on reconnect.
  void startListening() {
    connectivity.onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        flushQueue();
      }
    });
  }

  /// Immediately attempts to upload all pending rated stories.
  Future<void> flushQueue() async {
    try {
      final pending = await getPendingUploads();
      if (pending.isEmpty) return;

      log('UploadQueueService: flushing ${pending.length} pending uploads');
      final deviceId = deviceIdService.deviceId;

      for (final story in pending) {
        await _uploadSingle(story, deviceId);
      }
    } catch (e) {
      log('UploadQueueService: flush failed — $e');
    }
  }

  Future<void> _uploadSingle(PlayedStory story, String deviceId) async {
    try {
      final storyModel = StoryModel(
        title: story.story.title,
        intro: story.story.intro,
        crimeDescription: story.story.crimeDescription,
        suspects: story.story.suspects
            .map(
              (s) => SuspectModel(
                name: s.name,
                suspiciousBehavior: s.suspiciousBehavior,
              ),
            )
            .toList(),
        clues: story.story.clues
            .map((c) => ClueModel(text: c.text, difficulty: c.difficulty))
            .toList(),
        twist: story.story.twist,
        killerName: story.story.killerName,
      );

      final storyId = await uploadStory(storyModel.toJson(), deviceId);

      if (story.userRating != null) {
        await rateCommunityStory(storyId, story.userRating!, deviceId);
      }

      await markAsUploaded(story.id);
      log('UploadQueueService: uploaded story ${story.id}');
    } catch (e) {
      log('UploadQueueService: failed to upload story ${story.id} — $e');
      // Leave in queue so next flush retries it
    }
  }
}
