import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/story.dart';
import 'story_title_widget.dart';
import 'story_card_widget.dart';
import 'story_suspects_info_widget.dart';

class StoryContentWidget extends StatelessWidget {
  final Story story;

  const StoryContentWidget({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            radius: const Radius.circular(8),
            thickness: 6,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(right: 12), // Add padding for scrollbar
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
            ),
          ),
        ),
        // Gentle hint to scroll down
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Center(
            child: Icon(
              Icons.keyboard_double_arrow_down,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
              size: 24,
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .moveY(begin: -4, end: 4, duration: 1.seconds),
          ),
        ),
      ],
    );
  }
}
