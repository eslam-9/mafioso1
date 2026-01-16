# Mafioso 🕵️‍♂️🎭

**Mafioso** is a modern, AI-powered reimagining of the classic social deduction party game "Mafia" (also known as Werewolf). 

Gone are the days of needing a human moderator to sit out the fun. Mafioso uses **Google Gemini AI** to act as an infinite, dynamic Narrator, cultivating unique and immersive stories for every single game session.

---

## ✨ Features

- **🤖 AI Narrator**: Powered by the Gemini API, the game generates unique murder mystery narratives based on player actions in real-time.
- **🌍 Bilingual Support**: Fully localized for both **English** and **Arabic** speakers.
- **⚡ Offline Mode**: Internet down? The game seamlessly falls back to a library of pre-generated thrillers so the fun never stops.
- **🎭 Classic Roles**:
  - **🔪 Killer**: Eliminate the innocents at night.
  - **🕵️‍♂️ Detective**: Investigate roles to find the truth.
  - **🩺 Doctor**: Save one person from elimination each night.
  - **👥 Civilians**: Deduce, discuss, and vote to survive.
- **🗳️ In-App Voting**: Integrated voting system to democratically eliminate suspects during the day phase.
- **🎨 Premium Aesthetic**: A sleek, dark-themed UI designed for late-night gaming sessions.

## 📱 Screens

| Role Reveal | Story Mode | Voting Phase |
|:-----------:|:----------:|:------------:|
| ![Role Reveal](assets/images/logo.png) | ![Story](assets/images/logo.png) | ![Voting](assets/images/logo.png) |

*(Note: Replace reference images with actual screenshots)*

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (SDK 3.8.1+)
- **Language**: Dart
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- **AI Integration**: [Google Gemini API](https://ai.google.dev/)
- **Localization**: [easy_localization](https://pub.dev/packages/easy_localization)
- **Styling**: Custom Dark Theme / Flutter ScreenUtil
- **Network**: Dio

## 🚀 Getting Started

Follow these steps to get a local copy up and running.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- Android Studio / VS Code with Flutter extensions.
- A valid **Gemini API Key** from [Google AI Studio](https://aistudio.google.com/).

### Installation

1. **Clone the repo**
   ```bash
   git clone https://github.com/yourusername/mafioso.git
   cd mafioso
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Environment**
   Create a `.env` file in the root directory:
   ```env
   GEMINI_API_KEY=your_api_key_here
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

## 🎮 How to Play

1. **Setup**: Select the number of players (minimum 4).
2. **Role Reveal**: Pass the phone around. Each player sees their secret role.
3. **Night Phase**:
   - The **Killer** chooses a victim.
   - The **Detective** investigates a player.
   - The **Doctor** chooses someone to save.
4. **Day Phase**: 
   - The AI narrates the events of the night (who died, who was saved).
   - Players discuss and debate who the Killer is.
5. **Voting**: Players vote to eliminate a suspect.
6. **Win Condition**: 
   - **Innocents Win**: If the Killer is eliminated.
   - **Killer Wins**: If the Killer outnumbers or equals the Innocents.

## 📦 Building for Release

To build an APK for Android:

```bash
flutter build apk --release
```
The output file will be located at `build/app/outputs/flutter-apk/app-release.apk`.

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---
*Built with ❤️ by Eslam Abozied*
