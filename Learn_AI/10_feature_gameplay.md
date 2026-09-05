# 10 — Feature: Gameplay (Game Result)

## Overview
The core game loop: players read the story, reveal clues progressively, and vote to eliminate suspects each round until someone wins.

## OOB Behavior
- Two tabs: "Story & Clues" and "Voting"
- Story tab: displays story intro, suspects, and clues (revealed progressively)
- Voting tab: each alive player casts a vote for a suspect
- Submit votes → system processes elimination
- Round result dialog shows who was eliminated
- Game continues until:
  - Killer eliminated → Innocents win
  - Killer alive and ≤2 players remain → Killer wins
- Win/lose sound plays on game end
- Navigate to summary screen

## Architecture

### Domain
```
domain/
└── entities/
    └── game_state.dart    # GameState enum: playing, innocentsWin, killerWins
```

### Presentation
```
presentation/
├── bloc/
│   ├── game_bloc.dart
│   ├── game_event.dart
│   └── game_state.dart
├── pages/
│   ├── game_page.dart
│   └── summary_page.dart
└── widgets/
    ├── game_tabs.dart          # Tab switcher
    ├── story_tab.dart          # Story + clues display
    ├── vote_tab.dart           # Voting form
    ├── clues_list_widget.dart
    ├── suspects_list_widget.dart
    ├── vote_form_widget.dart
    ├── reveal_clue_button.dart
    ├── submit_votes_button.dart
    ├── voting_dialog.dart
    ├── round_result_dialog.dart
    ├── elimination_dialog.dart
    ├── round_info_widget.dart
    ├── killer_reveal_widget.dart
    ├── story_twist_widget.dart
    ├── game_stats_widget.dart
    ├── summary_result_banner.dart
    ├── summary_actions.dart
    └── story_card_widget.dart
```

### Voting Domain (shared)
```
voting/domain/entities/
├── vote.dart           # Single vote: voterId → suspectId
└── vote_result.dart    # Round result with most-voted calculation
```

## Design Patterns
- **State Machine**: Game transitions between playing → win/loss states
- **Strategy Pattern**: Clue sorting by difficulty (hardest first)
- **Mediator Pattern**: GameBloc coordinates between voting, clues, and game state
- **Observer Pattern**: UI reacts to BLoC state changes

## SOLID Principles
- **Single Responsibility**: 
  - `GameBloc` handles game state only
  - `VoteResult` calculates most-voted player
  - Each widget handles one display concern
- **Open/Closed**: New game states can be added to `GameState` enum
- **Liskov Substitution**: Domain `GameState` and presentation `GameState` coexist with different namespaces
- **Interface Segregation**: `GameBloc` events are specific to game actions
- **Dependency Inversion**: Uses domain entities (`VoteResult`, `GameState`)

## BLoC Details
### Events
- `InitGame(players, story)` — Set up initial game state
- `RevealNextClue` — Reveal next clue in difficulty order
- `SubmitVotes(List<Vote>)` — Process all votes for current round
- `ResetGame` — Clear all state

### State (presentation)
```dart
class GameState extends Equatable {
  final List<Player> players;
  final Story? story;
  final domain.GameState gameState;  // playing, innocentsWin, killerWins
  final int currentRound;
  final List<VoteResult> voteHistory;
  final List<Clue> revealedClues;
  final AppError? error;
  
  List<Player> get alivePlayers => players.where((p) => p.isAlive).toList();
  List<Clue> get availableClues => story?.clues ?? [];
  bool get canRevealMoreClues => revealedClues.length < availableClues.length;
}
```

### Vote Processing Logic
```dart
// 1. Validate votes not empty
// 2. Calculate most-voted player via VoteResult
// 3. Eliminate player (isAlive = false)
// 4. Check win conditions:
//    - Eliminated player was killer → innocentsWin
//    - Killer alive AND aliveCount <= 2 → killerWins
// 5. If still playing → increment round
// 6. Emit new state
```

## Clue Sorting
```dart
final sortedClues = List<Clue>.from(event.story.clues)
  ..sort((a, b) => b.difficulty.index.compareTo(a.difficulty.index));
// Hardest clues first (descending difficulty)
```

## Data Flow
```
GamePage receives players + story from route args
  → creates GameBloc inline
  → dispatches InitGame
  → BLoC sorts clues, sets initial state
  
User taps "Reveal Clue" → RevealNextClue
  → BLoC adds next clue to revealedClues list
  
User fills votes → SubmitVotes
  → BLoC processes elimination, checks win conditions
  → Shows round result dialog
  → If game over → navigate to summary
  → If still playing → next round
```

## Edge Cases
- **Empty votes**: Throws `AppError('error_empty_votes')`
- **Player not found**: Throws `AppError('error_player_not_found')`
- **Tie votes**: `VoteResult.mostVotedPlayerId` returns null → no elimination, round increments
- **All clues revealed**: `canRevealMoreClues` returns false, button disabled
- **No alive players to vote**: Should not happen (game ends before this)

## Namespace Collision Handling
```dart
// Domain game state
import '../../domain/entities/game_state.dart' as domain;
// Presentation game state
import 'game_state.dart' as presentation;

// Usage:
domain.GameState.playing       // enum value
presentation.GameState()       // BLoC state class
```
