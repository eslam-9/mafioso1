import 'dart:math';
import '../../../../features/game_setup/domain/entities/game_config.dart';
import '../../../../features/story/domain/entities/story.dart';
import '../../../../features/story/data/models/suspect_model.dart';
import '../entities/player.dart';

class AssignRolesUseCase {
  List<Player> call({required GameConfig config, required Story story}) {
    final random = Random();
    final playerNames = List<String>.from(config.playerNames);

    // Assign roles
    final roles = <PlayerRole>[];
    roles.add(PlayerRole.killer);

    if (config.hasDetective) {
      roles.add(PlayerRole.detective);
    }

    while (roles.length < config.totalPlayers) {
      roles.add(PlayerRole.innocent);
    }

    roles.shuffle(random);

    // Create players
    final players = <Player>[];
    for (int i = 0; i < playerNames.length; i++) {
      players.add(
        Player(id: 'player_$i', name: playerNames[i], role: roles[i]),
      );
    }

    // Assign story characters to players
    if (story.suspects.isNotEmpty) {
      final killerSuspect = (story.suspects as List<SuspectModel>).firstWhere(
        (s) => s.name == story.killerName,
        orElse: () => story.suspects.first as SuspectModel,
      );

      final otherSuspects =
          story.suspects.where((s) => s.name != killerSuspect.name).toList()
            ..shuffle(random);

      int suspectIndex = 0;

      for (int i = 0; i < players.length; i++) {
        if (players[i].role == PlayerRole.killer) {
          players[i] = players[i].copyWith(
            storyCharacterName: killerSuspect.name,
            storyCharacterBehavior: killerSuspect.suspiciousBehavior,
          );
        } else if (players[i].role != PlayerRole.detective) {
          if (suspectIndex < otherSuspects.length) {
            players[i] = players[i].copyWith(
              storyCharacterName: otherSuspects[suspectIndex].name,
              storyCharacterBehavior:
                  otherSuspects[suspectIndex].suspiciousBehavior,
            );
            suspectIndex++;
          }
        }
      }
    }

    return players;
  }
}
