# 07 — Feature: Game Setup

## Overview
Handles game configuration: mode selection (with/without detective), suspect count (4-6), and player name entry with validation.

## OOB Behavior
- Default: without detective mode, 4 suspects
- Suspect count selector: 4, 5, or 6 buttons
- Player name inputs: dynamic count based on mode + suspect count
- Validation: all names must be non-empty and unique
- Continue button: disabled until validation passes
- On continue: navigates to story generation with `GameConfig`

## Architecture

### Domain
```
domain/
└── entities/
    └── game_config.dart    # GameMode enum, suspectCount, playerNames
```

### Presentation
```
presentation/
├── bloc/
│   ├── game_setup_bloc.dart
│   ├── game_setup_event.dart
│   └── game_setup_state.dart
├── pages/
│   └── player_setup_page.dart
└── widgets/
    ├── suspect_count_selector.dart
    ├── suspect_count_button.dart
    ├── player_name_inputs.dart
    ├── player_name_input.dart
    └── continue_button.dart
```

### No Data Layer
This feature has no data layer — it's pure UI state management.

## Design Patterns
- **State Machine**: BLoC manages valid/invalid states based on input
- **Event Chaining**: `SetPlayerName` → auto-dispatches `ValidateNames`
- **Composition**: `PlayerNameInputs` composes multiple `PlayerNameInput` widgets

## SOLID Principles
- **Single Responsibility**: `GameSetupBloc` only handles setup state. Each widget handles one UI concern.
- **Open/Closed**: New game modes can be added to `GameMode` enum without changing validation logic.
- **Liskov Substitution**: `GameConfig` can be passed through navigation as route argument.
- **Interface Segregation**: BLoC exposes only what the UI needs through its state.
- **Dependency Inversion**: BLoC has no external dependencies — pure state management.

## BLoC Details
### Events
- `SetGameMode(GameMode)` — Toggle detective mode
- `SetSuspectCount(int)` — Change suspect count (4-6)
- `SetPlayerName(int index, String name)` — Update player name at index
- `ValidateNames` — Validate all names (auto-dispatched)
- `ResetGameSetup` — Clear all state

### State
```dart
class GameSetupState extends Equatable {
  final GameMode selectedMode;    // withDetective | withoutDetective
  final int suspectCount;          // 4, 5, or 6
  final List<String> playerNames;  // Dynamic length
  final bool isValid;              // All names non-empty + unique
}
```

### Validation Logic
```dart
bool _validateNames(List<String> names) {
  if (names.any((name) => name.trim().isEmpty)) return false;
  final uniqueNames = names.map((n) => n.trim().toLowerCase()).toSet();
  return uniqueNames.length == names.length;
}
```

## Data Flow
```
User selects suspect count → SetSuspectCount event → 
  BLoC updates playerNames list → auto-dispatches ValidateNames → 
  emits new state with isValid flag → Continue button enabled/disabled

User enters name → SetPlayerName event → 
  BLoC updates name at index → auto-dispatches ValidateNames → 
  emits new state

User taps Continue → Navigator.pushNamed with GameConfig arguments
```

## Edge Cases
- Suspect count change: preserves existing names, truncates or pads with empty strings
- Mode change: adjusts total player count (suspects + detective if applicable)
- Duplicate names: validation fails, continue button disabled
- Empty names: validation fails
