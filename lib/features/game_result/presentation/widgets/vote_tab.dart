import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_state.dart' as presentation;
import 'vote_form_widget.dart';
import 'submit_votes_button.dart';

class VoteTab extends StatefulWidget {
  const VoteTab({super.key});

  @override
  State<VoteTab> createState() => _VoteTabState();
}

class _VoteTabState extends State<VoteTab> {
  final Map<String, String?> _votes = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, presentation.GameState>(
      builder: (context, state) {
        final alivePlayers = state.alivePlayers;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.how_to_vote, size: 48, color: AppColors.bloodRed),
                      const SizedBox(height: 12),
                      Text(
                        'صوّت عشان تستبعد',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.bloodRed,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'كل لاعب يصوت على اللي يفتكر إنه القاتل',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.lightGray,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 24),
              Text(
                'صوّتوا دلوقتي',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.bloodRed,
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 16),
              VoteFormWidget(
                alivePlayers: alivePlayers,
                votes: _votes,
                onVoteChanged: (voterId, accusedId) {
                  setState(() {
                    _votes[voterId] = accusedId;
                  });
                },
              ),
              const SizedBox(height: 24),
              SubmitVotesButton(
                votes: _votes,
                alivePlayers: alivePlayers,
                onSubmitted: () {
                  setState(() {
                    _votes.clear();
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
