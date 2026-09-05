import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../shared/widgets/story_status_badge.dart';
import '../bloc/story_library_bloc.dart';
import '../bloc/story_library_event.dart';
import '../bloc/story_library_state.dart';
import '../../domain/entities/community_story.dart';
import '../../../story_history/presentation/widgets/story_rating_widget.dart';

class StoryLibraryPage extends StatelessWidget {
  const StoryLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StoryLibraryBloc(
        getCommunityStories: getIt(),
        rateCommunityStory: getIt(),
        deviceIdService: getIt(),
      )..add(LoadCommunityStories()),
      child: const _StoryLibraryView(),
    );
  }
}

class _StoryLibraryView extends StatefulWidget {
  const _StoryLibraryView();

  @override
  State<_StoryLibraryView> createState() => _StoryLibraryViewState();
}

class _StoryLibraryViewState extends State<_StoryLibraryView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<StoryLibraryBloc>().add(LoadMoreCommunityStories());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('community_library'.tr())),
      body: BlocBuilder<StoryLibraryBloc, StoryLibraryState>(
        builder: (context, state) {
          if (state is StoryLibraryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StoryLibraryError) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<StoryLibraryBloc>().add(LoadCommunityStories()),
            );
          }
          if (state is StoryLibraryLoaded) {
            if (state.stories.isEmpty) {
              return _EmptyView();
            }
            return ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16.w),
              itemCount: state.stories.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.stories.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _CommunityStoryCard(
                  story: state.stories[index],
                  index: index,
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CommunityStoryCard extends StatefulWidget {
  final CommunityStory story;
  final int index;

  const _CommunityStoryCard({required this.story, required this.index});

  @override
  State<_CommunityStoryCard> createState() => _CommunityStoryCardState();
}

class _CommunityStoryCardState extends State<_CommunityStoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rating = widget.story.bayesianRating;

    return Card(
          margin: EdgeInsets.only(bottom: 14.h),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // — Header: title + community badge + expand indicator
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.story.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      const StoryStatusBadge(status: StoryStatus.community),
                      SizedBox(width: 8.w),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: theme.colorScheme.outline,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // — Rating bar
                  _RatingRow(rating: rating, votes: widget.story.totalVotes),
                  SizedBox(height: 8.h),

                  // — Intro preview
                  Text(
                    widget.story.intro,
                    maxLines: _expanded ? null : 2,
                    overflow: _expanded ? null : TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  // — Expanded content
                  if (_expanded) ...[
                    SizedBox(height: 16.h),
                    const Divider(),
                    SizedBox(height: 8.h),

                    // Rating widget for user to rate
                    Text(
                      'rate_this_story'.tr(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    StoryRatingWidget(
                      onRatingSelected: (r) => context
                          .read<StoryLibraryBloc>()
                          .add(RateCommunityStory(widget.story.id, r)),
                    ),
                    SizedBox(height: 14.h),

                    // Play button
                    FilledButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        RouteNames.playerSetup,
                        arguments: {
                          'existingStory': widget.story.storyJson,
                          'fromCommunity': true,
                        },
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: Text('play_this_story'.tr()),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9F43),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: widget.index * 60))
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOut);
  }
}

class _RatingRow extends StatelessWidget {
  final double rating;
  final int votes;

  const _RatingRow({required this.rating, required this.votes});

  @override
  Widget build(BuildContext context) {
    final filled = rating.round().clamp(0, 5);

    return Row(
      children: [
        // Star row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            5,
            (i) => Icon(
              i < filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 16,
              color: Colors.amber,
            ),
          ),
        ),
        SizedBox(width: 6.w),
        // Numeric
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.amber,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          '($votes)',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
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
          Icon(
            Icons.public_off_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          SizedBox(height: 16.h),
          Text(
            'no_community_stories'.tr(),
            textAlign: TextAlign.center,
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
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 52,
            color: Theme.of(context).colorScheme.outline,
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(message, textAlign: TextAlign.center),
          ),
          SizedBox(height: 16.h),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('retry'.tr()),
          ),
        ],
      ),
    );
  }
}
