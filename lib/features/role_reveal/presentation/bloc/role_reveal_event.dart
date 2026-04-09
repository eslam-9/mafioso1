import 'package:equatable/equatable.dart';
import '../../../../features/game_setup/domain/entities/game_config.dart';
import '../../../../features/story/domain/entities/story.dart';

abstract class RoleRevealEvent extends Equatable {
  const RoleRevealEvent();

  @override
  List<Object?> get props => [];
}

class AssignRoles extends RoleRevealEvent {
  final GameConfig config;
  final Story story;

  const AssignRoles({required this.config, required this.story});

  @override
  List<Object?> get props => [config, story];
}

class NextPlayer extends RoleRevealEvent {
  const NextPlayer();
}

class MarkCurrentRevealed extends RoleRevealEvent {
  const MarkCurrentRevealed();
}

class ResetRoleReveal extends RoleRevealEvent {
  const ResetRoleReveal();
}
