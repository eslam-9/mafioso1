import 'package:flutter/material.dart';
import 'story_tab.dart';
import 'vote_tab.dart';

class GameTabs extends StatelessWidget {
  final TabController tabController;

  const GameTabs({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: const [
        StoryTab(),
        VoteTab(),
      ],
    );
  }
}
