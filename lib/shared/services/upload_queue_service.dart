import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/logger.dart';
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

  final Set<String> _blockedLocalIds = <String>{};

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
      AppLogger.logInfo(
        'UploadQueueService: connectivity changed=$results hasConnection=$hasConnection',
      );
      if (hasConnection) {
        AppLogger.logInfo(
          'UploadQueueService: triggering flush after connectivity restore',
        );
        flushQueue();
      }
    });
  }

  /// Immediately attempts to upload all pending rated stories.
  Future<void> flushQueue() async {
    AppLogger.logInfo('UploadQueueService: flushQueue start');
    try {
      final pending = await getPendingUploads();
      if (pending.isEmpty) {
        AppLogger.logInfo(
          'UploadQueueService: no rated pending stories to upload',
        );
        return;
      }

      log('UploadQueueService: flushing ${pending.length} pending uploads');
      AppLogger.logInfo(
        'UploadQueueService: flushing pending count=${pending.length}',
      );
      final deviceId = deviceIdService.deviceId;
      AppLogger.logInfo(
        'UploadQueueService: using deviceId=${deviceId.isEmpty ? "(empty)" : deviceId}',
      );

      for (final story in pending) {
        if (_blockedLocalIds.contains(story.id)) {
          AppLogger.logInfo(
            'UploadQueueService: skip blocked localId=${story.id}',
          );
          continue;
        }
        AppLogger.logInfo(
          'UploadQueueService: upload candidate localId=${story.id} title="${story.story.title}" rating=${story.userRating}',
        );
        await _uploadSingle(story, deviceId);
      }
      AppLogger.logInfo('UploadQueueService: flushQueue done');
    } catch (e) {
      AppLogger.logError('UploadQueueService.flushQueue', e);
      log('UploadQueueService: flush failed — $e');
    }
  }

  Future<void> _uploadSingle(PlayedStory story, String deviceId) async {
    try {
      AppLogger.logInfo(
        'UploadQueueService: begin upload localId=${story.id} rating=${story.userRating}',
      );
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

      AppLogger.logInfo(
        'UploadQueueService: upload metadata localId=${story.id} lang=${story.languageCode}',
      );
      final storyId = await uploadStory(
        storyModel.toJson(),
        deviceId,
        story.languageCode,
      );
      AppLogger.logInfo(
        'UploadQueueService: uploadStory success localId=${story.id} remoteId=$storyId',
      );

      if (story.userRating != null) {
        await rateCommunityStory(storyId, story.userRating!, deviceId);
        AppLogger.logInfo(
          'UploadQueueService: rateCommunityStory success remoteId=$storyId rating=${story.userRating}',
        );
      }

      await markAsUploaded(story.id);
      AppLogger.logInfo(
        'UploadQueueService: markAsUploaded success localId=${story.id}',
      );
      log('UploadQueueService: uploaded story ${story.id}');
    } catch (e) {
      AppLogger.logError(
        'UploadQueueService._uploadSingle localId=${story.id}',
        e,
      );
      log('UploadQueueService: failed to upload story ${story.id} — $e');

      if (_isRlsDenied(e)) {
        _blockedLocalIds.add(story.id);
        AppLogger.logInfo(
          'UploadQueueService: blocking further retries for localId=${story.id} (RLS denied). Fix Supabase RLS policy or enable authenticated uploads.',
        );
        return;
      }

      // Leave in queue so next flush retries it
    }
  }

  bool _isRlsDenied(Object e) {
    if (e is PostgrestException) {
      return e.code == '42501' ||
          e.message.toLowerCase().contains('row-level security');
    }
    final text = e.toString().toLowerCase();
    return text.contains('row-level security') || text.contains('code: 42501');
  }
}
