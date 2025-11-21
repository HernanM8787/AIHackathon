# AeQuus

AeQuus is a SwiftUI iOS app that helps college students stay balanced by combining calendar, assignments, health data, and AI-powered coaching in one experience. It was originally created for the Kennesaw State University AI Hackathon.

## Why AeQuus?

- **Personal stress insights:** Heart-rate history, stress-level forecasting, and AI guidance give students visibility into how classes and habits affect wellbeing.
- **Centralized planning:** Events from Apple Calendar, custom assignments, reminders, and AI task suggestions are merged into a single dashboard.
- **Support & reflection:** Anonymous peer sharing, daily reflections, and a chat-based assistant (powered by Google Gemini) provide accountability and encouragement.

## Feature Highlights

| Area | What’s inside |
| --- | --- |
| **Dashboard** | Stress graph/focus card, heart-rate trends, daily reflection, upcoming events and assignments, peer-support shortcut |
| **Calendar** | Unified events view, hourly itinerary with AI suggestions, day-specific assignments and reminders |
| **Assignments** | Firebase-backed CRUD, optional Apple Reminders integration, progress tracking on the home screen |
| **AI Assistant** | Chat UI that leverages Gemini for task guidance, stress forecasts, and contextual prompts triggered throughout the app |
| **Health & habit data** | HealthKit heart-rate fetch, stress history, mood insights |
| **Peer Support** | Anonymous forum backed by Firestore, live comments, filters, “My Posts” view |

## Project Structure

```
AIHackathon/
├── App/                   # AppState, root entry points
├── Auth/                  # Signup/signin flows and account info
├── Components/            # Reusable SwiftUI components
├── Config/                # Gemini config
├── Dashboard/             # Home dashboard experience
├── Events/                # Calendar, suggestions, assignments
├── Models/                # Data types (Event, Assignment, StressSample, etc.)
├── Services/              # Firebase, HealthKit, Calendar, Stress analysis
├── Chat/                  # AI Assistant and reflection screens
├── Utils/                 # Helpers, storage, permission persistence
└── README.md
```

## Local Setup

1. **Clone & open**
   ```bash
   git clone git@github.com:your-org/AIHackathon.git
   cd AIHackathon
   open AIHackathon.xcodeproj
   ```
2. **Set the display name (optional)**  
   In `Info.plist`, update `Bundle display name` if you want the icon to read “AeQuus”.
3. **Install dependencies**
   - Firebase, HealthKit, and other frameworks are integrated via Swift Package Manager. Resolve packages in Xcode if prompted.
4. **Provisioning**  
   Set your team and bundle identifier under `Signing & Capabilities` so you can run on device.

## Gemini API setup

AeQuus uses Google’s Gemini models for the assistant, stress-level analysis, and AI suggestions. Keep API keys outside source control:

### Xcode
1. `Product → Scheme → Edit Scheme…`
2. Select the `Run` action → **Arguments** tab.
3. Under **Environment Variables**, add:
   - `GEMINI_API_KEY` = `your-secret`
   - `GEMINI_MODEL` (optional) = e.g. `gemini-pro`
4. Run the app; `GeminiConfig` loads the values automatically.

### Command line
```bash
export GEMINI_API_KEY="your-secret"
export GEMINI_MODEL="gemini-pro"
xcodebuild -scheme AIHackathon … # or use your preferred run command
```

### Temporary fallback (not for commits)
You can set the fallback string in `Config/GeminiConfig.swift`, but remove it before pushing to avoid leaking secrets.

## Firebase & Data

- **Firestore** powers events, assignments, peer-support posts, and stress samples. Update `GoogleService-Info.plist` with your Firebase project details.
- **HealthKit** access requires enabling the capability plus setting the usage descriptions in `Info.plist`.
- **Calendar & Reminders** use EventKit; make sure `NSCalendarsUsageDescription` and `NSRemindersUsageDescription` are present.

## Running the App

1. Press `⌘R` in Xcode after provisioning and setting env vars.
2. Complete onboarding by granting calendar/reminder/health permissions.
3. Sign up (email + password). Face ID/Keychain integration is available after login.
4. Explore the Home dashboard, Calendar tab, Assistant, and Forum.

## Contributing

Open issues or PRs with improvements. Please avoid committing secrets or personal data. Key areas for contribution:

- Better AI prompts and caching for the assistant/stress services
- Additional HealthKit metrics
- UI polish for assignments/calendar
- Automated tests for services and views

---

Built with SwiftUI, Combine, Firebase, EventKit, HealthKit, and Google’s Gemini API to give students a calmer, smarter campus experience.
