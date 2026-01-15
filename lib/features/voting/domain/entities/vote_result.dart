import '../../../game_result/domain/entities/game_state.dart' as domain;
import 'vote.dart';

class VoteResult {
  final int round;
  final List<Vote> votes;
  final String? eliminatedPlayerId;
  final String? eliminatedPlayerName;
  final domain.GameState gameState;

  const VoteResult({
    required this.round,
    required this.votes,
    this.eliminatedPlayerId,
    this.eliminatedPlayerName,
    required this.gameState,
  });

  Map<String, int> get voteTally {
    final tally = <String, int>{};
    for (var vote in votes) {
      tally[vote.accusedId] = (tally[vote.accusedId] ?? 0) + 1;
    }
    return tally;
  }

  String? get mostVotedPlayerId {
    if (votes.isEmpty) return null;

    final tally = voteTally;
    final maxVotes = tally.values.reduce((a, b) => a > b ? a : b);
    final playersWithMaxVotes = tally.entries
        .where((entry) => entry.value == maxVotes)
        .map((entry) => entry.key)
        .toList();

    if (playersWithMaxVotes.length > 1) return null;

    return playersWithMaxVotes.first;
  }
}
