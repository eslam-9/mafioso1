import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/game_player.dart';
import '../bloc/online_room_bloc.dart';
import '../bloc/online_room_event.dart';

class OnlineVoteTab extends StatefulWidget {
  final List<GamePlayer> alivePlayers;

  const OnlineVoteTab({
    super.key,
    required this.alivePlayers,
  });

  @override
  State<OnlineVoteTab> createState() => _OnlineVoteTabState();
}

class _OnlineVoteTabState extends State<OnlineVoteTab> {
  String? _selectedPlayerId;
  final _currentUserId = getIt<AuthService>().currentUserId;

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

    final currentPlayer = widget.alivePlayers.firstWhere(
      (p) => p.userId == _currentUserId,
      orElse: () => widget.alivePlayers.first,
    );
    
    // If player is dead, they can only spectate
    if (!currentPlayer.isAlive) {
      return Center(
        child: Text(
          'You are dead and cannot vote.',
          style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.error),
        ),
      );
    }

    // Players they can vote for
    final votingOptions = widget.alivePlayers.where((p) => p.id != currentPlayer.id).toList();

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
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 24),
          
          if (!currentPlayer.hasVoted) ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedPlayerId,
              decoration: InputDecoration(
                hintText: 'select_suspect'.tr(),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              items: votingOptions.map((suspect) {
                return DropdownMenuItem<String>(
                  value: suspect.id,
                  child: Text(
                    suspect.displayName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPlayerId = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _selectedPlayerId != null
                  ? () {
                      context.read<OnlineRoomBloc>().add(
                            SubmitGameEventRequested(
                              eventType: 'cast_vote',
                              payload: {'accusedId': _selectedPlayerId},
                            ),
                          );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bloodRed,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Submit Vote',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ).animate().fadeIn(delay: 400.ms),
          ] else ...[
            Center(
              child: Text(
                'Waiting for other players to vote...',
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
