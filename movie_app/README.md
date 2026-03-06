# Movie App (TH3)

This Flutter app demonstrates a movie list using Firebase Firestore as the data source. It includes loading, success, and error UI states and separates code into models, services, and UI.

Important: Update the student information in `lib/main.dart` to match your name and student ID.

## Files added
- `lib/models/movie.dart` - Movie model
- `lib/services/firestore_service.dart` - Firestore fetch with try-catch
- `lib/screens/movie_list_screen.dart` - Main screen with loading/success/error states
- `lib/widgets/movie_card.dart` - Item card UI
- `lib/widgets/error_retry.dart` - Error UI with retry button

## Firebase / Firestore setup
1. Create a Firebase project and add Android/iOS apps (follow Firebase docs).
2. Add `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) to your project as instructed by Firebase.
3. Enable Firestore in the Firebase console.
4. Create a collection named `movies` and add documents with fields:
   - `title` (string) - movie title
   - `description` (string, optional)
   - `posterUrl` (string, optional) - direct image URL
   - `year` (number, optional)

Example document:

```
{
  "title": "The Matrix",
  "description": "A computer hacker learns about the true nature of reality.",
  "posterUrl": "https://example.com/matrix.jpg",
  "year": 1999
}
```

## Run
1. Update `lib/main.dart` student constants if needed.
2. Run `flutter pub get`.
3. Run app on a device or emulator:

```bash
flutter run
```

# Detailed Firebase setup (Android & iOS)

Android
- Register Android app in Firebase console with the Android package name (check `android/app/src/main/AndroidManifest.xml`).
- Download `google-services.json` and place it in `android/app/`.
- In `android/build.gradle` add Google services classpath if not present (Firebase setup usually does this automatically):

```gradle
buildscript {
  dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
  }
}
```

- In `android/app/build.gradle` add at the bottom:

```gradle
apply plugin: 'com.google.gms.google-services'
```

iOS
- Register an iOS app in Firebase console with the iOS bundle id (check `ios/Runner/Info.plist` or Xcode project settings).
- Download `GoogleService-Info.plist` and add it to the Xcode project (`Runner` target). Ensure it's included in the app bundle.

Optional: generate `firebase_options.dart` (recommended)
- Install FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
```

- From the project root run:

```bash
flutterfire configure
```

This will guide you and generate a `lib/firebase_options.dart` configured for your Firebase project. If you prefer not to run the CLI, replace the placeholders in `lib/firebase_options.dart` created by this project with your project's values.

Notes:
- The app calls `Firebase.initializeApp()` in `lib/main.dart`. On Android/iOS you can rely on `google-services.json` / `GoogleService-Info.plist` being present so no explicit `FirebaseOptions` are required.
- For web/desktop platforms you must supply `FirebaseOptions` (use FlutterFire CLI to generate them).
# movie_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
