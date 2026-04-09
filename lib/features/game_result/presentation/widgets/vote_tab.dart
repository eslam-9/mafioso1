import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../role_reveal/domain/entities/player.dart';
import '../../../voting/domain/entities/vote.dart';

class VoteTab extends StatefulWidget {
  final List<Player> alivePlayers;
  final Function(List<Vote>) onVotesSubmitted;

  const VoteTab({
    super.key,
    required this.alivePlayers,
    required this.onVotesSubmitted,
  });

  @override
  State<VoteTab> createState() => _VoteTabState();
}

class _VoteTabState extends State<VoteTab> {
  final Map<String, String?> _votes = {};

  @override
  void initState() {
    super.initState();
    // Initialize votes for each alive player
    for (var player in widget.alivePlayers) {
      _votes[player.id] = null;
    }
  }

  @override
  void didUpdateWidget(VoteTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update votes map when alive players change
    final newVotes = <String, String?>{};
    for (var player in widget.alivePlayers) {
      final existingVote = _votes[player.id];
      // Only preserve vote if the accused player is still alive
      if (existingVote != null &&
          widget.alivePlayers.any((p) => p.id == existingVote)) {
        newVotes[player.id] = existingVote;
      } else {
        newVotes[player.id] = null;
      }
    }
    _votes.clear();
    _votes.addAll(newVotes);
  }

  bool get _allVotesSubmitted {
    return _votes.values.every((vote) => vote != null);
  }

  void _submitVotes() {
    final votes = <Vote>[];

    for (var entry in _votes.entries) {
      if (entry.value != null) {
        final voter = widget.alivePlayers.firstWhere((p) => p.id == entry.key);
        final accused = widget.alivePlayers.firstWhere(
          (p) => p.id == entry.value,
        );

        // Detective vote counts as 2, others count as 1
        final voteWeight = voter.role == PlayerRole.detective ? 2 : 1;

        votes.add(
          Vote(
            voterId: voter.id,
            voterName: voter.name,
            accusedId: accused.id,
            accusedName: accused.name,
            voteWeight: voteWeight,
          ),
        );
      }
    }

    widget.onVotesSubmitted(votes);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.alivePlayers.isEmpty) {
      return Center(
        child: Text(
          'no_alive_players'.tr(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.how_to_vote, color: AppColors.bloodRed),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'vote_to_eliminate'.tr(),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'each_player_votes'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'detective_double_vote'.tr(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 24),

          // Individual voting cards for each alive player
          ...widget.alivePlayers.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;

            // Get list of players this player can vote for (excluding themselves)
            final votingOptions = widget.alivePlayers
                .where((p) => p.id != player.id)
                .toList();

            return Padding(
              key: ValueKey(player.id),
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.smokeGray
                    : Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: player.role == PlayerRole.detective
                                ? AppColors.bloodRed
                                : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onSurface),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              player.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          if (player.role == PlayerRole.detective)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bloodRed,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'x2',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _votes[player.id],
                        decoration: InputDecoration(
                          hintText: 'select_suspect'.tr(),
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        dropdownColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        items: votingOptions.map((suspect) {
                          return DropdownMenuItem<String>(
                            value: suspect.id,
                            child: Text(
                              suspect.name,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _votes[player.id] = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (300 + index * 100).ms),
            );
          }),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _allVotesSubmitted ? _submitVotes : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bloodRed,
              padding: const EdgeInsets.symmetric(vertical: 16),
              disabledBackgroundColor:
                  Theme.of(context).brightness == Brightness.dark
                  ? AppColors.smokeGray
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Text(
              'submit_all_votes'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}
