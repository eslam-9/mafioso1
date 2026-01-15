import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../role_reveal/domain/entities/player.dart' as player_entity;

class VoteFormWidget extends StatelessWidget {
  final List<player_entity.Player> alivePlayers;
  final Map<String, String?> votes;
  final Function(String voterId, String? accusedId) onVoteChanged;

  const VoteFormWidget({
    super.key,
    required this.alivePlayers,
    required this.votes,
    required this.onVoteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: alivePlayers.map((voter) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voter.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: votes[voter.id],
                    decoration: const InputDecoration(
                      labelText: 'اتهم',
                      prefixIcon: Icon(Icons.gavel),
                    ),
                    items: alivePlayers
                        .where((p) => p.id != voter.id)
                        .map((player) => DropdownMenuItem(
                              value: player.id,
                              child: Text(player.name),
                            ))
                        .toList(),
                    onChanged: (value) => onVoteChanged(voter.id, value),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (200 + alivePlayers.indexOf(voter) * 50).ms),
        );
      }).toList(),
    );
  }
}
