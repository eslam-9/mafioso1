import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_community_stories_usecase.dart';
import '../../domain/usecases/rate_community_story_usecase.dart';
import '../../../../core/services/device_id_service.dart';
import 'story_library_event.dart';
import 'story_library_state.dart';

class StoryLibraryBloc extends Bloc<StoryLibraryEvent, StoryLibraryState> {
  final GetCommunityStoriesUseCase getCommunityStories;
  final RateCommunityStoryUseCase rateCommunityStory;
  final DeviceIdService deviceIdService;

  static const int _pageSize = 20;
  int _currentPage = 0;
  final List _loadedStories = [];

  StoryLibraryBloc({
    required this.getCommunityStories,
    required this.rateCommunityStory,
    required this.deviceIdService,
  }) : super(StoryLibraryInitial()) {
    on<LoadCommunityStories>(_onLoad);
    on<LoadMoreCommunityStories>(_onLoadMore);
    on<RateCommunityStory>(_onRate);
  }

  Future<void> _onLoad(
    LoadCommunityStories event,
    Emitter<StoryLibraryState> emit,
  ) async {
    emit(StoryLibraryLoading());
    _currentPage = 0;
    _loadedStories.clear();
    try {
      final stories = await getCommunityStories(page: 0);
      _loadedStories.addAll(stories);
      emit(
        StoryLibraryLoaded(
          stories: List.from(_loadedStories),
          hasMore: stories.length == _pageSize,
        ),
      );
    } catch (e) {
      emit(StoryLibraryError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreCommunityStories event,
    Emitter<StoryLibraryState> emit,
  ) async {
    if (state is! StoryLibraryLoaded) return;
    final current = state as StoryLibraryLoaded;
    if (!current.hasMore) return;

    try {
      _currentPage++;
      final stories = await getCommunityStories(page: _currentPage);
      _loadedStories.addAll(stories);
      emit(
        StoryLibraryLoaded(
          stories: List.from(_loadedStories),
          hasMore: stories.length == _pageSize,
        ),
      );
    } catch (_) {
      // Keep showing existing stories on pagination error
      _currentPage--;
    }
  }

  Future<void> _onRate(
    RateCommunityStory event,
    Emitter<StoryLibraryState> emit,
  ) async {
    try {
      await rateCommunityStory(
        event.storyId,
        event.rating,
        deviceIdService.deviceId,
      );
    } catch (_) {
      // Silent fail — user's rating stored locally via story_history already
    }
  }
}
