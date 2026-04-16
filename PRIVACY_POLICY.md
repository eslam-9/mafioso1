# Privacy Policy

**Effective Date:** 2026-04-10

Eslam Abozied built the **Mafioso** app as a Free/Ad-Supported/Premium app. This SERVICE is provided by Eslam Abozied at no cost and is intended for use "as is". 

This Privacy Policy explains how your information is handled when you use the Mafioso application. Given the nature of a local "pass-and-play" party game, we deeply value your privacy and have architected the app to ask for minimal permissions and collect zero personally identifiable information (PII).

## Data Collection and Use

**1. Personal Information and Gameplay Data**
- All gameplay happens locally on your device.
- Player names entered during the "Game Setup" phase are used strictly for local gameplay mechanics (e.g., assigning roles and resolving game results). **These names are never transmitted to any external server.**

**2. Third-Party Story Generation (Google Gemini API)**
To provide dynamic and unique murder mystery narratives, Mafioso uses the **Google Gemini API**. 
When generating a new story, the application sends only the following generic parameters to the API:
- The total number of generic suspects (`suspectCount`).
- Whether the game includes a Detective role (`hasDetective`).
- Your device's selected language output (`languageCode`).

**No player names, identities, or personal data are ever included in the prompt sent to Google's servers.** Note that whenever your device makes external network requests, your IP address is inherently exposed to the service provider. For more information on how Google handles API requests, please review [Google's Privacy Policy](https://policies.google.com/privacy).

**3. Offline Functionality**
The application uses local device connectivity checks to determine if you are online. If an active internet connection is unavailable, it securely defaults to a library of pre-generated offline stories embedded entirely within the app.

## Analytics, Tracking, and Cookies

Mafioso is designed to be lightweight and private:
- The app **does not** integrate with Google Analytics, Firebase Crashlytics, or other tracking platforms.
- The app **does not** collect, transmit, or store crash logs.
- The app **does not** use browser cookies or any persistent local storage for tracking. 

## Children’s Privacy

Because the app does not collect personal data, it does not collect data from children. However, the themes of the app (a "murder mystery" social deduction game) may not be suitable for very young audiences. We do not knowingly solicit personal information from anyone under the age of 13.

## Security

We value your trust in our application. All communication from the application to the narrative generation service (Google Gemini) is done securely over encrypted HTTPS connections. Because your actual gameplay and player names exist only in your device's memory and are cleared when the game concludes, your data remains fully private.

## Changes to This Privacy Policy

We may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page.

## Contact Us

If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact Eslam Abozied.
