import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_state.dart' as presentation;
import 'story_card_widget.dart';
import 'round_info_widget.dart';
import 'suspects_list_widget.dart';
import 'clues_list_widget.dart';
import 'reveal_clue_button.dart';

class StoryTab extends StatelessWidget {
  const StoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, presentation.GameState>(
      builder: (context, state) {
        if (state.story == null) {
          return Center(child: Text('error_no_story'.tr()));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StoryCardWidget(story: state.story!),
              const SizedBox(height: 24),
              RoundInfoWidget(
                round: state.currentRound,
                aliveCount: state.alivePlayers.length,
                revealedClues: state.revealedClues.length,
                totalClues: state.availableClues.length,
              ),
              const SizedBox(height: 24),
              SuspectsListWidget(suspects: state.story!.suspects),
              const SizedBox(height: 24),
              CluesListWidget(clues: state.revealedClues),
              const SizedBox(height: 16),
              if (state.canRevealMoreClues) const RevealClueButton(),
            ],
          ),
        );
      },
    );
  }
}
