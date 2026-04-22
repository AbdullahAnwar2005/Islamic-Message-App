# Islamic Message

An elegant, performant Flutter application providing daily Islamic messages, audio recitations, and Quran-based content.

## Core Features
1. **Daily Messages & Translations**: Read carefully curated Islamic content with precise translations.
2. **Offline-First Reading & Audio**: Built on a solid local database cache so the app works seamlessly without an internet connection.
3. **Advanced Audio Player**: Background audio support, speed controls, and robust state management powered by `just_audio`.
4. **Rich UI/UX**: Built with modern Flutter principles, fully supporting Light and Dark modes along with adaptive typography for accessibility.
5. **Analytics & Sync**: Integrated offline queueing for analytics, ensuring content interactions are resiliently tracked and synchronized.

## Tech Stack
- **Framework**: Flutter
- **State Management**: Riverpod (`flutter_riverpod`)
- **Local Database**: Drift (SQLite)
- **Backend / BaaS**: Supabase
- **Audio**: `just_audio`, `just_audio_background`

## Setup & Running the App

This project enforces strict build-time configuration using `dart-define` to inject environment variables securely.

### Important Security Note
*There are no hardcoded secrets, `.env` files, or API keys in this repository.* All sensitive credentials must be passed at compile-time. Safe public configurations are built into the app logic, while server-only secrets remain securely configured on the deployment backend.

### Build Instructions

To build or run the app locally, you **must** provide the Supabase arguments:

```bash
flutter run \
  --dart-define=SUPABASE_URL="https://YOUR-SUPABASE-URL.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="YOUR-SUPABASE-ANON-KEY"
```

To build an APK for release:
```bash
flutter build apk \
  --dart-define=SUPABASE_URL="..." \
  --dart-define=SUPABASE_ANON_KEY="..."
```

## Project Status
The app is currently in active development, focusing on final release readiness, robust offline sync, and advanced analytics integrations.
