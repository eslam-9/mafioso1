import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart';
import '../../../story_library/presentation/bloc/story_library_bloc.dart';
import '../../../story_library/presentation/bloc/story_library_event.dart';
import '../../../story_library/presentation/bloc/story_library_state.dart';
import '../../../story_library/domain/entities/community_story.dart';

class GameSelectionSheet extends StatelessWidget {
  final int? currentMemberCount;

  const GameSelectionSheet({
    super.key,
    this.currentMemberCount,
  });

  static Future<CommunityStory?> show(
    BuildContext context, {
    int? currentMemberCount,
  }) {
    return showModalBottomSheet<CommunityStory>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider(
        create: (_) =>
            getIt<StoryLibraryBloc>()
              ..add(LoadCommunityStories(languageCode: context.locale.languageCode)),
        child: GameSelectionSheet(currentMemberCount: currentMemberCount),
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
                        final isSuitable = currentMemberCount == null || story.suspectCount == currentMemberCount;

                        return ListTile(
                          title: Text(story.title),
                          subtitle: Text(
                            '${'rating'.tr()}: ${story.bayesianRating.toStringAsFixed(1)} ★ | ${'suspects'.tr()}: ${story.suspectCount}',
                          ),
                          trailing: isSuitable
                              ? null
                              : const Icon(Icons.warning, color: Colors.orange),
                          onTap: () {
                            Navigator.pop(context, story);
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
