# Mafioso Game Documentation

## 1. Project Overview
**Mafioso** is a reimagined version of the classic "Mafia" or "Werewolf" social deduction game. It modernizes the experience by replacing the human narrator with an **AI Storyteller** (powered by Google Gemini), creating immersive, dynamic, and unique narratives for every session. The app is built with **Flutter** and follows **Clean Architecture** principles to ensure scalability and maintainability.

## 2. Technical Architecture
The project adheres to **Clean Architecture** combined with the **BLoC (Business Logic Component)** pattern for state management. This separation of concerns ensures that the codebase is modular, testable, and independent of external frameworks.

### Layers:
1.  **Presentation Layer (`presentation`)**: 
    -   Contains UI components (`Widgets`, `Pages`) and State Management (`Blocs`/`Cubits`).
    -   Responsible for displaying data and capturing user events.
2.  **Domain Layer (`domain`)**: 
    -   The core business logic.
    -   Contains `Entities` (pure Dart objects), `Repositories` (interfaces), and `Use Cases` (specific business actions).
    -   Strictly independent of data sources and UI.
3.  **Data Layer (`data`)**: 
    -   Implementations of the domain repositories.
    -   Contains `Data Sources` (Remote APIs, Local Storage) and `Models` (DTOs with parsing logic).

## 3. Project Structure
The `lib` directory is organized by features (modular approach) and core utilities:

```text
lib/
├── core/                   # Shared utilities and configurations
│   ├── constants/          # App-wide constants
│   ├── di/                 # Dependency Injection setup (GetIt)
│   ├── errors/             # Custom exception and failure classes
│   ├── localization/       # Localization logic (EasyLocalization)
│   ├── routing/            # Navigation and route definitions
│   └── theme/              # App theme, colors, and fonts
├── features/               # Modular features of the application
│   ├── game_setup/         # Player name entry and game configuration
│   ├── home/               # Landing page/Main menu
│   ├── role_reveal/        # Screens for revealing individual roles
│   ├── story/              # Narrative generation (Gemini integration)
│   ├── voting/             # Voting interface and logic
│   └── game_result/        # Elimination and Game Over logic
├── shared/                 # Shared UI widgets used across multiple features
├── app.dart                # Main material app widget
└── main.dart               # App entry point
```

## 4. Key Features & Implementation Details

### 4.1. AI Storyteller (Gemini API)
-   **Implementation**: Utilizes the Google Gemini API to generate narratives.
-   **Logic**:
    -   The app sends the current game state (e.g., who died, who was investigated) to Gemini.
    -   Gemini returns a short, suspenseful story describing the events.
-   **Offline Fallback**: If the internet is unavailable, the app falls back to a pre-defined JSON library of generic stories (`stories_offline_en.json` / `stories_offline_ar.json`).

### 4.2. Game Logic & Roles
The game supports standard roles with specific abilities:
-   **Killer**: Chooses a victim to eliminate each night.
-   **Detective**: Investigates one player's role each night. *Special Ability: Votes count as 2 during the day phase.*
-   **Doctor**: Chooses one player to save each night.
-   **Civilian**: No special night abilities; participates in discussions and voting.

### 4.3. Voting System
-   **Mechanism**: Players vote synchronously on their devices (pass-and-play or simplified local UI).
-   **Rules**:
    -   Self-voting is disabled.
    -   Eliminated players cannot vote.
    -   Detective's vote has double weight.
    -   The player with the most votes is eliminated (unless there is a tie, usually resulting in no elimination).

### 4.4. Localization (i18n)
-   **Package**: `easy_localization`
-   **Supported Languages**: English (`en`) and Arabic (`ar`).
-   **Implementation**: Strings are stored in JSON files in `assets/translations/`. The app dynamically switches layout direction (LTR/RTL) based on the selected language.

### 4.5. State Management
-   **Library**: `flutter_bloc`
-   **Pattern**: Each feature typically has its own Bloc/Cubit (e.g., `GameBloc`, `StoryBloc`, `VotingCubit`) to handle specific logic and UI states.

## 5. Setup & Dependencies

### Core Dependencies
-   `flutter_bloc`: State management.
-   `get_it`: Dependency injection.
-   `dio`: HTTP client for API calls.
-   `easy_localization`: Internationalization.
-   `flutter_screenutil`: Responsive UI sizing.
-   `google_fonts`: Custom typography.

### Environment Management
-   The app uses `flutter_dotenv` to manage sensitive keys.
-   **Required**: A `.env` file in the root directory containing `GEMINI_API_KEY`.

## 6. How to Run
1.  Ensure **Flutter** is installed (`flutter doctor`).
2.  Clone the repository.
3.  Add your Gemini API key to `.env`.
4.  Run `flutter pub get` to install dependencies.
5.  Run `flutter run` to start the app on an emulator or physical device.
