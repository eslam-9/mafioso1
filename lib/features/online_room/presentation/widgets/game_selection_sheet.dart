import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart';
import '../../../story_library/presentation/bloc/story_library_bloc.dart';
import '../../../story_library/presentation/bloc/story_library_event.dart';
import '../../../story_library/presentation/bloc/story_library_state.dart';
import '../bloc/online_room_bloc.dart';
import '../bloc/online_room_event.dart';

class GameSelectionSheet extends StatelessWidget {
  final int maxPlayers;
  final OnlineRoomBloc roomBloc;

  const GameSelectionSheet({
    super.key,
    required this.maxPlayers,
    required this.roomBloc,
  });

  static Future<void> show(BuildContext context, int maxPlayers) {
    final roomBloc = context.read<OnlineRoomBloc>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider(
        create: (_) =>
            getIt<StoryLibraryBloc>()
              ..add(const LoadCommunityStories(languageCode: 'en')),
        child: GameSelectionSheet(maxPlayers: maxPlayers, roomBloc: roomBloc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'select_story'.tr(),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: BlocBuilder<StoryLibraryBloc, StoryLibraryState>(
                builder: (context, state) {
                  if (state is StoryLibraryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is StoryLibraryError) {
                    return Center(child: Text(state.message));
                  } else if (state is StoryLibraryLoaded) {
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: state.stories.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.stories.length) {
                          context.read<StoryLibraryBloc>().add(
                            LoadMoreCommunityStories(),
                          );
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final story = state.stories[index];
                        final isSuitable = story.suspectCount >= maxPlayers;

                        return ListTile(
                          title: Text(story.title),
                          subtitle: Text(
                            '${'rating'.tr()}: ${story.bayesianRating.toStringAsFixed(1)} ★ | ${'suspects'.tr()}: ${story.suspectCount}',
                          ),
                          trailing: isSuitable
                              ? null
                              : const Icon(Icons.warning, color: Colors.orange),
                          onTap: () {
                            roomBloc.add(
                              SelectGameRequested(
                                storyId: story.id,
                                gameMode: 'standard',
                              ),
                            );
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
