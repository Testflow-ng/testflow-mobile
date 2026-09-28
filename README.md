# TestFlow Mobile

The Flutter mobile application for TestFlow, a computer-based testing platform for students. It supports subjects, examinations, results, progress, achievements, and offline question-bank experiences.

## Requirements

- Flutter SDK (stable channel)
- Dart SDK, supplied with Flutter
- Android Studio/Xcode for Android or iOS builds

## Run locally

```bash
git clone https://github.com/Testflow-ng/testflow-mobile.git
cd testflow-mobile
flutter pub get
flutter run
```

## API configuration

The app defaults to the hosted TestFlow API. To point a local build to another API, supply `API_URL` when running it:

```bash
flutter run --dart-define=API_URL=http://localhost:5000
```

For an Android emulator, use `http://10.0.2.2:5000` to reach a backend running on your computer.

## Useful commands

```bash
flutter analyze  # Check code quality
flutter test     # Run tests
flutter build apk
flutter build ios
```

## Related repositories

- [Frontend](https://github.com/Testflow-ng/testflow-frontend)
- [Backend API](https://github.com/Testflow-ng/testflow-backend)
