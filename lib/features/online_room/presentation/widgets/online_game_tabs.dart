import 'package:flutter/material.dart';
import '../../domain/entities/game_player.dart';
import 'online_story_tab.dart';
import 'online_vote_tab.dart';

class OnlineGameTabs extends StatelessWidget {
  final TabController tabController;
  final List<GamePlayer> alivePlayers;

  const OnlineGameTabs({
    super.key,
    required this.tabController,
    required this.alivePlayers,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: [
        const OnlineStoryTab(),
        OnlineVoteTab(alivePlayers: alivePlayers),
      ],
    );
  }
}
