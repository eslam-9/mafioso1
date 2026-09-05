# 09 — Feature: Role Reveal

## Overview
Sequential pass-the-device role assignment. Each player sees their role (Killer, Detective, or Innocent) one at a time, then passes the device to the next player.

## OOB Behavior
- Roles are randomly shuffled and assigned to players
- One player is always the Killer
- If detective mode: one player is Detective
- Remaining players are Innocents
- Each player taps to reveal their role, then taps "Next" to pass to next player
- Progress bar shows current player / total players
- Role names are localized (AR/EN)
- Sound effect plays on role reveal

## Architecture

### Domain
```
domain/
├── entities/
│   └── player.dart    # Player with role, name, isAlive, hasRevealed
├── usecases/
│   └── assign_roles_usecase.dart    # Shuffles and assigns roles
```

### Presentation
```
presentation/
├── bloc/
│   ├── role_reveal_bloc.dart
│   ├── role_reveal_event.dart
│   └── role_reveal_state.dart
├── pages/
│   └── role_reveal_page.dart
└── widgets/
    ├── role_reveal_progress.dart    # Progress indicator
    ├── role_reveal_content.dart     # Role display content
    └── role_reveal_action_button.dart    # Reveal/Next button
```

### No Data Layer
Roles are generated in-memory, no persistence needed.

## Design Patterns
- **Strategy Pattern**: Role assignment algorithm based on game mode
- **Observer Pattern**: BLoC streams state changes to UI
- **Template Method**: Base error pattern for localization

## SOLID Principles
- **Single Responsibility**: `AssignRolesUseCase` only assigns roles. BLoC only manages reveal state.
- **Open/Closed**: New roles can be added to `PlayerRole` enum without changing the BLoC.
- **Liskov Substitution**: `Player` entity is used consistently across features.
- **Interface Segregation**: UseCase has single `call()` method.
- **Dependency Inversion**: BLoC depends on `AssignRolesUseCase` abstraction.

## Role Assignment Logic (AssignRolesUseCase)
```dart
List<Player> call({required GameConfig config, required Story story}) {
  final shuffledNames = List.from(config.playerNames)..shuffle();
  
  // First player is always the killer
  players.add(Player(name: shuffledNames[0], role: PlayerRole.killer));
  
  // If detective mode, second player is detective
  if (config.hasDetective) {
    players.add(Player(name: shuffledNames[1], role: PlayerRole.detective));
  }
  
  // Remaining players are innocents
  for (int i = (config.hasDetective ? 2 : 1); i < shuffledNames.length; i++) {
    players.add(Player(name: shuffledNames[i], role: PlayerRole.innocent));
  }
  
  return players;
}
```

## BLoC Details
### Events
- `AssignRoles(GameConfig, Story)` — Shuffle and assign
- `NextPlayer` — Move to next player
- `MarkCurrentRevealed` — Mark current player as having seen their role
- `ResetRoleReveal` — Clear state

### State
```dart
class RoleRevealState extends Equatable {
  final List<Player> players;
  final int currentPlayerIndex;
  
  Player? get currentPlayer => players[currentPlayerIndex];
  bool get hasNextPlayer => currentPlayerIndex < players.length - 1;
  bool get isComplete => currentPlayerIndex >= players.length;
}
```

## Data Flow
```
RoleRevealPage receives players + story from route args
  → creates RoleRevealBloc with AssignRolesUseCase
  → dispatches AssignRoles
  → BLoC shuffles and assigns roles
  → emits state with players list
  
User taps "Reveal" → MarkCurrentRevealed
  → BLoC marks player.hasRevealed = true
  
User taps "Next" → NextPlayer
  → BLoC increments currentPlayerIndex
  
All players revealed → navigate to game screen
```

## Edge Cases
- **Single player**: Not possible (minimum 4 suspects)
- **Role leak**: UI shows "pass device" screen between players
- **Re-entry**: State is lost on navigation back — roles would need re-assignment
