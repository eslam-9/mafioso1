# Mafioso - Production Readiness Plan & Review

## 1. App Brief: What is Mafioso?
**Mafioso** is an AI-powered murder mystery party game that eliminates the need for a human moderator. 
- **Core Loop:** The app uses LLMs (**Google Gemini** and **Groq**) to generate unique mystery scenarios (suspects, clues, and a logical twist). Players receive secret roles (Killer, Innocent, or Detective), investigate clues, and vote to eliminate suspects until the killer is caught or the innocents lose.
- **Key Features:** Supports offline play with bundled stories, multi-language (English/Arabic), local history tracking via **Hive**, and a community library hosted on **Supabase**.
- **Tech Stack:** Built with a clean, feature-driven architecture using **Flutter BLoC**, **GetIt** (DI), **Dio** (Networking), and **ScreenUtil** (Responsive UI).

## 2. Production Readiness Assessment
The project is in a high-quality state with a solid architectural foundation. However, there are a few **critical blockers** and **polish items** remaining before it can be considered production-ready.

**Strengths:**
- **Security:** Correctly utilizes `dart-define` for API keys instead of bundling `.env` files.
- **Resilience:** Graceful fallbacks for missing AI keys and offline scenarios.
- **Architecture:** Excellent separation of concerns; domain entities are pure and independent of data models or localization.
- **Performance:** Implements responsive design and efficient list builders.

**Weaknesses:**
- **Web Compatibility:** The `ConnectivityService` uses `dart:io`, which will cause a crash on Flutter Web.
- **Testing:** Test coverage is currently minimal; the core logic for AI parsing and game rules needs validation.
- **Optimization:** R8/ProGuard shrinking and obfuscation are not yet enabled for Android.

## 3. Developer Brief ("The Ring")
*Hey Eslam! Great work on Mafioso. The app has a solid foundation with a clean architecture and a robust AI story generation engine. You've correctly moved away from risky `.env` files to `dart-define` for secrets, and your BLoC implementation handles the game state beautifully. The multi-language support (EN/AR) is a huge plus for reach.*

*However, there are a few hurdles before we're truly 'Production Ready'. The biggest blocker right now is the `dart:io` usage in `ConnectivityService`, which will break your Web build. Also, while you've got local and community libraries working, we need to shore up the testing—specifically around AI response parsing—to ensure weird LLM outputs don't crash the game for users. Once we enable ProGuard and fix the web compatibility, we're looking at a very polished release candidate!*

---

## 4. Production Readiness Action Plan

### Phase 1: Critical Fixes & Compatibility
- [ ] **Fix Web Compatibility:** Refactor `ConnectivityService` to use a web-safe approach (e.g., conditional imports or a package like `http` for pinging) instead of `dart:io`.
- [ ] **Verify AI Endpoints:** Check the model name `gemini-2.5-flash` in `StoryRemoteDataSource`. (Likely `gemini-1.5-flash` or `gemini-2.0-flash-exp`).
- [ ] **Cleanup:** Formally remove or implement the unused `AiProviderCubit`.

### Phase 2: Testing & Reliability
- [ ] **Robust AI Parsing Tests:** Add unit tests for `StoryModel.fromJson` using various mock AI responses (including malformed JSON and "hallucinated" fields).
- [ ] **Game Logic Tests:** Write BLoC tests for `GameBloc` to verify edge cases like tie votes or final elimination rounds.

### Phase 3: Hardening & Optimization
- [ ] **Release Configuration:** Enable R8/ProGuard in `android/app/build.gradle` and configure `proguard-rules.pro`.
- [ ] **Signing Security:** Ensure release signing keys are managed via local `keystore.properties` (added to `.gitignore`).
- [ ] **CI/CD:** Set up a simple GitHub Actions workflow to automate `flutter analyze` and `flutter test`.

### Phase 4: Final Polish
- [ ] **UI Audit:** Verify that `ScreenUtil` handles extremely small or large phone screens without overflows.
- [ ] **Theme Verification:** Confirm the theme persistence works as expected on physical devices.
