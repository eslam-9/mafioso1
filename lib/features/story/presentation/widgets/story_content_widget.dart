import 'package:flutter/material.dart';
import '../../domain/entities/story.dart';
import 'story_title_widget.dart';
import 'story_card_widget.dart';
import 'story_suspects_info_widget.dart';

class StoryContentWidget extends StatelessWidget {
  final Story story;

  const StoryContentWidget({
    super.key,
    required this.story,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StoryTitleWidget(title: story.title),
          const SizedBox(height: 24),
          StoryCardWidget(
            intro: story.intro,
            crimeDescription: story.crimeDescription,
          ),
          const SizedBox(height: 16),
          StorySuspectsInfoWidget(suspectCount: story.suspects.length),
        ],
      ),
    );
  }
}
