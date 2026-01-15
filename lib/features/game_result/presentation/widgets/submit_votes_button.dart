import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../shared/services/sound_service.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../../../voting/domain/entities/vote.dart';
import '../../../role_reveal/domain/entities/player.dart' as player_entity;
import 'round_result_dialog.dart';

class SubmitVotesButton extends StatelessWidget {
  final Map<String, String?> votes;
  final List<player_entity.Player> alivePlayers;
  final VoidCallback onSubmitted;

  const SubmitVotesButton({
    super.key,
    required this.votes,
    required this.alivePlayers,
    required this.onSubmitted,
  });

  bool get _canSubmit {
    return votes.length == alivePlayers.length &&
        votes.values.every((vote) => vote != null);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _canSubmit ? () => _submitVotes(context) : null,
      child: Text('submit_votes'.tr()),
    ).animate().fadeIn(delay: 400.ms);
  }

  Future<void> _submitVotes(BuildContext context) async {
    try {
      di.getIt<SoundService>().playSound(SoundEffect.vote);
    } catch (e) {
      // Sound service might not be available
    }

    final bloc = context.read<GameBloc>();
    final state = bloc.state;

    final voteList = votes.entries.map((entry) {
      final voter = state.players.firstWhere((p) => p.id == entry.key);
      final accused = state.players.firstWhere((p) => p.id == entry.value);
      return Vote(
        voterId: voter.id,
        voterName: voter.name,
        accusedId: accused.id,
        accusedName: accused.name,
      );
    }).toList();

    bloc.add(SubmitVotes(voteList));
    onSubmitted();

    // Show result dialog if game not over
    if (!bloc.state.isGameOver && bloc.state.voteHistory.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => RoundResultDialog(
          result: bloc.state.voteHistory.last,
        ),
      );
    }
  }
}
