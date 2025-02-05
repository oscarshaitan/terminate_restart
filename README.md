# 🔄 Terminate Restart

[![pub package](https://img.shields.io/pub/v/terminate_restart.svg)](https://pub.dev/packages/terminate_restart)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://github.com/sleem2012/terminate_restart/workflows/Flutter%20CI/badge.svg)](https://github.com/sleem2012/terminate_restart/actions)
[![codecov](https://codecov.io/gh/sleem2012/terminate_restart/branch/main/graph/badge.svg)](https://codecov.io/gh/sleem2012/terminate_restart)
[![likes](https://img.shields.io/pub/likes/terminate_restart)](https://pub.dev/packages/terminate_restart/score)
[![popularity](https://img.shields.io/pub/popularity/terminate_restart)](https://pub.dev/packages/terminate_restart/score)
[![pub points](https://img.shields.io/pub/points/terminate_restart)](https://pub.dev/packages/terminate_restart/score)

A robust Flutter plugin for terminating and restarting your app with extensive customization options. Perfect for implementing dynamic updates, clearing app state, or refreshing your app's UI.

## 🌟 Features

- ✨ **Two Restart Modes**:
  - UI-only restart (recreate activities/views)
  - Full process termination and restart
- 🧹 **Smart Data Management**:
  - Optional data clearing during restart
  - Configurable data preservation options
  - Proper cleanup of app state
- 🔒 **Secure Data Handling**:
  - Preserve keychain data
  - Preserve user defaults/shared preferences
  - Clean process termination
- 📱 **Platform Support**:
  - ✅ Android
  - ✅ iOS (coming soon)
- 🎨 **Rich UI Options**:
  - Customizable confirmation dialogs
  - Immediate mode for quick restarts
  - Beautiful default UI
- ⚡ **Performance**:
  - Minimal initialization delay
  - Optimized process handling
  - Clean state management

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  terminate_restart: ^1.0.0
```

## 🚀 Getting Started

### Basic Usage

```dart
import 'package:terminate_restart/terminate_restart.dart';

// Simple UI-only restart
await TerminateRestart.restartApp(
  terminate: false, // false for UI-only restart
);

// Full process termination and restart
await TerminateRestart.restartApp(
  terminate: true, // true for full process termination
);
```

### Advanced Usage with Data Clearing

```dart
// Restart with data clearing
await TerminateRestart.restartApp(
  clearData: true, // Clear app data
  preserveKeychain: true, // Keep sensitive data
  preserveUserDefaults: false, // Clear preferences
  terminate: true, // Full process restart
);
```

### Confirmation Dialog

```dart
// Restart with custom confirmation dialog
await TerminateRestart.restartApp(
  context: context, // Required for dialog
  mode: RestartMode.withConfirmation,
  dialogTitle: '✨ Update Ready!',
  dialogMessage: 'Restart now to apply updates?',
  restartNowText: '🚀 Restart Now',
  restartLaterText: '⏰ Later',
  cancelText: '❌ Cancel',
);
```

### Error Handling

```dart
try {
  final success = await TerminateRestart.restartApp(
    terminate: true,
    clearData: true,
  );
  
  if (!success) {
    print('Restart cancelled or failed');
  }
} catch (e) {
  print('Error during restart: $e');
}
```

## 📱 Screenshots

<div style="display: flex; flex-direction: row;">
  <img src="screenshots/basic.png" width="250" alt="Basic Usage">
  <img src="screenshots/dialog.png" width="250" alt="Confirmation Dialog">
  <img src="screenshots/data_clearing.png" width="250" alt="Data Clearing">
</div>

## 📚 Complete Example

Check out our [example app](example) for a full demonstration of all features, including:

- Basic UI/Process restart
- Data clearing with preservation options
- Custom confirmation dialogs
- Error handling
- State management
- Platform-specific features

## 🔧 Platform-Specific Details

### Android Implementation

The Android implementation uses a combination of techniques to ensure reliable app restart:

```kotlin
// Activity recreation (UI-only restart)
currentActivity.recreate()

// Full process termination
Process.killProcess(Process.myPid())
exitProcess(0)

// Smart Intent handling
intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
```

### iOS Implementation (Coming Soon)

The iOS implementation will provide:

- Clean process termination
- State preservation options
- Keychain data handling
- User defaults management

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing`)
5. Open a Pull Request

Please read our [Contributing Guidelines](CONTRIBUTING.md) for details.

## 📋 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of all changes and updates.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

Made with ❤️ by Ahmed Sleem

---

<p align="center">
  <a href="https://github.com/sleem2012/terminate_restart">GitHub</a> •
  <a href="https://pub.dev/packages/terminate_restart">pub.dev</a> •
  <a href="https://github.com/sleem2012/terminate_restart/issues">Issues</a>
</p>
