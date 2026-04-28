# Privacy Policy

**Effective Date:** 2026-04-28

This Privacy Policy explains how information is handled when you use the **Mafioso** application.

Mafioso is a local “pass-and-play” party game. The app is designed to minimize data collection while still supporting optional online features (AI story generation and the community library).

## Data We Handle

### 1) Personal information
- Mafioso does not require you to create an account.
- Mafioso does not intentionally collect personally identifiable information (PII) such as real names, email addresses, or phone numbers.

### 2) Gameplay data (local)
- Player names you enter are used only for local gameplay (role reveal, voting, results).
- Gameplay state is processed locally on-device.

### 3) Saved stories (local storage)
Mafioso can store finished games on your device so you can replay them later. Stored data may include:
- Story content (title/intro/crime/suspects/clues/twist/killer name)
- Language code
- Play timestamp
- Your rating (if you rate)
- Upload status (whether a community upload was completed)

### 4) AI story generation (third-party providers)
If you provide API keys at build/run time (via `--dart-define` / `--dart-define-from-file`), Mafioso may generate stories using third-party AI providers (for example: Google Gemini and/or Groq).
- Mafioso sends a prompt containing game configuration such as suspect count and language preference.
- Mafioso is designed not to include the player names you enter in the prompt.
- When your device makes network requests, your IP address is visible to the service provider as part of normal internet communication.

### 5) Community library uploads (Supabase)
If you rate a story and community features are enabled, Mafioso may upload story data to a Supabase backend so it can appear in the community library.
- Uploaded data may include story JSON/content, language code, suspect count, a content hash (to prevent duplicates), and a device identifier used for deduplication/spam prevention.
- If you submit a rating for a community story, the rating and device identifier may be stored to prevent duplicate votes.
- Supabase will receive your IP address as part of standard network communication.

### 6) Connectivity checks
Mafioso uses connectivity checks to decide whether to attempt online generation/uploads or to fall back to offline stories.

## Analytics, Tracking, and Advertising
- Mafioso does not integrate with ad networks.
- Mafioso does not include third-party analytics/telemetry SDKs (e.g., Google Analytics / Firebase Crashlytics) by default.
- The app may write diagnostic logs locally (visible in device logs during development). These logs are not intentionally sent to our servers.
- The app uses local storage for app functionality (saved stories and preferences), not for cross-app tracking.

## Children’s Privacy
Mafioso does not intentionally collect personal data from children. However, the themes of the app (a “murder mystery” social deduction game) may not be suitable for very young audiences. We do not knowingly solicit personal information from anyone under the age of 13.

## Security
When Mafioso communicates with external services (AI providers and/or Supabase), it uses encrypted HTTPS connections. No method of transmission or storage is 100% secure; please use the app at your own discretion.

## Changes to This Privacy Policy
We may update this Privacy Policy from time to time. Please review it periodically for changes. Updates are effective when posted in the app repository/build.

## Contact Us
If you have any questions or suggestions about this Privacy Policy, please contact the developer (Eslam Abozied).

