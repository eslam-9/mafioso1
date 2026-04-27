import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../shared/widgets/story_status_badge.dart';
import '../bloc/story_history_bloc.dart';
import '../bloc/story_history_event.dart';
import '../bloc/story_history_state.dart';
import '../../domain/entities/played_story.dart';

class SavedStoriesPage extends StatelessWidget {
  const SavedStoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StoryHistoryBloc>()..add(LoadSavedStories()),
      child: const _SavedStoriesView(),
    );
  }
}

class _SavedStoriesView extends StatelessWidget {
  const _SavedStoriesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('saved_stories'.tr())),
      body: BlocBuilder<StoryHistoryBloc, StoryHistoryState>(
        builder: (context, state) {
          if (state is StoryHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StoryHistoryError) {
            return _ErrorView(message: state.message);
          } else if (state is StoryHistoryLoaded) {
            if (state.stories.isEmpty) {
              return _EmptyView();
            }
            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: state.stories.length,
              itemBuilder: (context, index) =>
                  _StoryCard(story: state.stories[index], index: index),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final PlayedStory story;
  final int index;

  const _StoryCard({required this.story, required this.index});

  StoryStatus get _status =>
      story.isUploaded ? StoryStatus.uploaded : StoryStatus.localOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
          margin: EdgeInsets.only(bottom: 14.h),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // — Header row: title + status badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        story.story.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    StoryStatusBadge(status: _status),
                  ],
                ),
                SizedBox(height: 6.h),

                // — Date + optional star rating
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: theme.colorScheme.outline,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      DateFormat.yMMMd().format(story.playedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    if (story.userRating != null) ...[
                      SizedBox(width: 12.w),
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '${story.userRating}/5',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.amber.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 12.h),

                // — Story intro preview
                Text(
                  story.story.intro,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 14.h),

                // — Play Again button
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      RouteNames.playerSetup,
                      arguments: {'existingStory': story.story},
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: Text('play_again'.tr()),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: index * 60))
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOut);
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.book_outlined, size: 64, color: theme.colorScheme.outline),
          SizedBox(height: 16.h),
          Text(
            'no_saved_stories'.tr(),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}
