import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../role_reveal/domain/entities/player.dart';
import '../../../voting/domain/entities/vote.dart';

class VotingDialog extends StatefulWidget {
  final List<Player> alivePlayers;
  final int totalPlayers;

  const VotingDialog({
    super.key,
    required this.alivePlayers,
    required this.totalPlayers,
  });

  @override
  State<VotingDialog> createState() => _VotingDialogState();
}

class _VotingDialogState extends State<VotingDialog> {
  final Map<int, String?> _votes = {};

  @override
  void initState() {
    super.initState();
    // Initialize votes for each player
    for (int i = 0; i < widget.totalPlayers; i++) {
      _votes[i] = null;
    }
  }

  bool get _allVotesSubmitted {
    return _votes.values.every((vote) => vote != null);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'vote_to_eliminate'.tr(),
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'each_player_votes'.tr(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(widget.totalPlayers, (playerIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'player'.tr(
                        namedArgs: {'index': (playerIndex + 1).toString()},
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _votes[playerIndex],
                      decoration: InputDecoration(
                        hintText: 'accuse'.tr(),
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
                      items: widget.alivePlayers.map((player) {
                        return DropdownMenuItem<String>(
                          value: player.id,
                          child: Text(
                            player.name,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _votes[playerIndex] = value;
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('understood'.tr()),
        ),
        ElevatedButton(
          onPressed: _allVotesSubmitted
              ? () {
                  final votes = _votes.entries
                      .where((entry) => entry.value != null)
                      .map((entry) {
                        final voterId = 'player_${entry.key}';
                        final voterName = 'player'.tr(
                          namedArgs: {'index': (entry.key + 1).toString()},
                        );
                        final accusedPlayer = widget.alivePlayers.firstWhere(
                          (p) => p.id == entry.value,
                        );
                        return Vote(
                          voterId: voterId,
                          voterName: voterName,
                          accusedId: entry.value!,
                          accusedName: accusedPlayer.name,
                        );
                      })
                      .toList();
                  Navigator.pop(context, votes);
                }
              : null,
          child: Text('submit_votes'.tr()),
        ),
      ],
    );
  }
}
