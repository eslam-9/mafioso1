import 'package:flutter/material.dart';
import '../../../role_reveal/domain/entities/player.dart';
import '../../../voting/domain/entities/vote.dart';
import 'story_tab.dart';
import 'vote_tab.dart';

class GameTabs extends StatelessWidget {
  final TabController tabController;
  final List<Player> alivePlayers;
  final Function(List<Vote>) onVotesSubmitted;

  const GameTabs({
    super.key,
    required this.tabController,
    required this.alivePlayers,
    required this.onVotesSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: [
        const StoryTab(),
        VoteTab(alivePlayers: alivePlayers, onVotesSubmitted: onVotesSubmitted),
      ],
    );
  }
}
