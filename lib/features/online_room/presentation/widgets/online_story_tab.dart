import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../bloc/online_room_bloc.dart';
import '../bloc/online_room_state.dart';
import '../bloc/online_room_event.dart';
import '../../../game_result/presentation/widgets/story_card_widget.dart';
import '../../../game_result/presentation/widgets/round_info_widget.dart';
import '../../../game_result/presentation/widgets/suspects_list_widget.dart';
import '../../../game_result/presentation/widgets/clues_list_widget.dart';

class OnlineStoryTab extends StatelessWidget {
  const OnlineStoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnlineRoomBloc, OnlineRoomState>(
      builder: (context, state) {
        if (state.story == null || state.session == null) {
          return Center(child: CircularProgressIndicator());
        }

        final isHost = state.isHost;
        final characterToPlayerMap = {
          for (var p in state.gamePlayers)
            if (p.storyCharacterName != null) p.storyCharacterName!: p.displayName,
        };

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StoryCardWidget(story: state.story!),
              const SizedBox(height: 24),
              RoundInfoWidget(
                round: state.session!.currentRound,
                aliveCount: state.alivePlayers.length,
                revealedClues: state.revealedClues.length,
                totalClues: state.availableClues.length,
              ),
              const SizedBox(height: 24),
              SuspectsListWidget(
                suspects: state.story!.suspects,
                characterToPlayerMap: characterToPlayerMap,
              ),
              const SizedBox(height: 24),
              CluesListWidget(clues: state.revealedClues),
              const SizedBox(height: 16),
              if (isHost && state.canRevealMoreClues)
                ElevatedButton(
                  onPressed: () {
                    final nextIndex = state.revealedClues.length;
                    context.read<OnlineRoomBloc>().add(
                          SubmitGameEventRequested(
                            eventType: 'reveal_clue',
                            payload: {'clueIndex': nextIndex},
                          ),
                        );
                  },
                  child: Text('reveal_next_clue'.tr()),
                ),
            ],
          ),
        );
      },
    );
  }
}
