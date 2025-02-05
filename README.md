# 🔄 Terminate Restart

[![pub package](https://img.shields.io/pub/v/terminate_restart.svg)](https://pub.dev/packages/terminate_restart)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
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

## 🚀 Usage

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

### Complete Example with State Management

```dart
class _MyHomePageState extends State<MyHomePage> {
  // Store persistent data
  late SharedPreferences _prefs;
  int _counter = 0;
  
  @override
  void initState() {
    super.initState();
    _loadCounter();
  }
  
  Future<void> _loadCounter() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = _prefs.getInt('counter') ?? 0;
    });
  }
  
  Future<void> _incrementCounter() async {
    setState(() {
      _counter++;
    });
    await _prefs.setInt('counter', _counter);
  }
  
  Future<void> _restartApp() async {
    final bool confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restart App'),
        content: Text('Do you want to clear data and restart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Yes, Restart'),
          ),
        ],
      ),
    ) ?? false;
    
    if (confirmed) {
      await TerminateRestart.restartApp(
        clearData: true,
        preserveKeychain: true,
        terminate: true,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Terminate Restart Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Counter: $_counter'),
            ElevatedButton(
              onPressed: _incrementCounter,
              child: Text('Increment'),
            ),
            ElevatedButton(
              onPressed: _restartApp,
              child: Text('Clear & Restart'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 📚 API Reference

### TerminateRestart.restartApp()

Main method to restart your app with various options:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| context | BuildContext? | null | Required for confirmation dialog |
| mode | RestartMode | immediate | Choose between immediate/confirmation |
| clearData | bool | false | Whether to clear app data |
| preserveKeychain | bool | false | Keep keychain data when clearing |
| preserveUserDefaults | bool | false | Keep user defaults when clearing |
| terminate | bool | true | Full process termination vs UI refresh |
| dialogTitle | String? | null | Custom title for confirmation dialog |
| dialogMessage | String? | null | Custom message for confirmation dialog |
| restartNowText | String? | null | Custom text for restart now button |
| restartLaterText | String? | null | Custom text for restart later button |
| cancelText | String? | null | Custom text for cancel button |

Returns `Future<bool>` indicating success or failure.

## 🔧 Platform-Specific Details

### Android

- Uses `Process.killProcess()` for clean termination
- Proper activity stack handling with Intent flags
- Smart SharedPreferences management
- Handles all app data directories

### iOS (Coming Soon)

- Clean process termination
- State preservation options
- Keychain data handling
- User defaults management

## 🤝 Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/amazing`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing`)
5. Create a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

Made with ❤️ by Ahmed Sleem

---

<p align="center">
  <a href="https://github.com/ahmedsleem/terminate_restart">GitHub</a> •
  <a href="https://pub.dev/packages/terminate_restart">pub.dev</a> •
  <a href="https://github.com/ahmedsleem/terminate_restart/issues">Issues</a>
</p>
