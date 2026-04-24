import 'dart:math';
import '../../../../features/game_setup/domain/entities/game_config.dart';
import '../../../../features/story/domain/entities/story.dart';
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
      // `story.suspects` may be backed by a `List<SuspectModel>` at runtime.
      // Copying into `List<Suspect>` avoids generic type mismatches in `firstWhere(orElse:)`.
      final suspects = List.from(story.suspects);

      final killerSuspect = suspects.firstWhere(
        (s) => s.name == story.killerName,
        orElse: () => suspects.first,
      );

      final otherSuspects =
          suspects.where((s) => s.name != killerSuspect.name).toList()
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
