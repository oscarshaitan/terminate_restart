# 🔄 Terminate Restart

[![pub package](https://img.shields.io/pub/v/terminate_restart.svg)](https://pub.dev/packages/terminate_restart)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![likes](https://img.shields.io/pub/likes/terminate_restart)](https://pub.dev/packages/terminate_restart/score)


A robust Flutter plugin for terminating and restarting your app with extensive customization options. Perfect for implementing dynamic updates, clearing app state, or refreshing your app's UI.

## 📱 Demo

<div align="center">
  <table>
    <tr>
      <td align="center">
        <img src="https://raw.githubusercontent.com/sleem2012/terminate_restart/main/.github/assets/demo.gif" alt="Plugin Demo" width="300"/>
        <br>
        <em>Plugin in Action</em>
      </td>
      <td align="center">
        <img src="https://raw.githubusercontent.com/sleem2012/terminate_restart/main/.github/assets/screenshot.png" alt="Plugin Interface" width="300"/>
        <br>
        <em>Clean & Simple Interface</em>
      </td>
    </tr>
  </table>
</div>

The demo showcases:
- 🔄 UI-only restart for quick refreshes
- 🚀 Full app termination and restart
- 🧹 Data clearing with preservation options
- 📝 Customizable confirmation dialogs
- ⚡ Smooth transitions and animations

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
  - ✅ iOS
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
  terminate_restart: ^1.0.4
```

### Permissions

No special permissions are required for either Android or iOS! The plugin uses only standard platform APIs:

#### Android
- No additional permissions needed in AndroidManifest.xml
- Uses standard Activity lifecycle methods
- No protected features accessed

#### iOS
- No special entitlements needed in Info.plist
- No additional capabilities required
- Uses standard UIKit methods

## 🚀 Getting Started

### Initialization

Initialize the plugin in your `main.dart`:

```dart
void main() {
  // Initialize the plugin with root reset handler
  TerminateRestart.instance.initialize(
    onRootReset: () {
      // This will be called during UI-only restarts
      // Reset your navigation to root
      // Clear navigation history
      // Reset any global state
      
      // Example with GetX:
      Get.reset();
      
      // Example with Provider:
      context.read<YourProvider>().reset();
      
      // Example with Bloc:
      context.read<YourBloc>().add(ResetEvent());
      
      // Example navigation reset:
      Navigator.of(context).popUntil((route) => route.isFirst);
    },
  );
  
  runApp(MyApp());
}
```

### Basic Usage

The plugin offers three restart modes:

1. **Full Restart (with termination)**
```dart
await TerminateRestart.instance.restartApp(
  options: TerminateRestartOptions(
    terminate: true,  // Fully terminate and restart
  ),
);
```

2. **UI-Only Restart (maintains connections)**
```dart
await TerminateRestart.instance.restartApp(
  options: TerminateRestartOptions(
    terminate: false,  // UI-only restart
  ),
);
```

3. **Restart with Data Clearing**
```dart
await TerminateRestart.instance.restartApp(
  options: TerminateRestartOptions(
    terminate: true,
    clearData: true,
    preserveKeychain: true,  // Optional: keep keychain data
    preserveUserDefaults: false,  // Optional: clear user defaults
  ),
);
```

### Restart Modes Comparison

| Feature | Full Restart | UI-Only Restart |
|---------|-------------|-----------------|
| Connections | ❌ Terminated | ✅ Maintained |
| State | ❌ Cleared | ✅ Resetable |
| Navigation | ❌ Cleared | ✅ Reset to Root |
| Speed | 🐢 Slower | 🚀 Faster |
| Memory | ✅ Fully Cleared | ⚠️ Preserved |
| Background Tasks | ❌ Terminated | ✅ Maintained |

### Common Use Cases

1. **Theme Switching**
```dart
// Use UI-only restart to switch themes smoothly
await TerminateRestart.instance.restartApp(
  options: TerminateRestartOptions(
    terminate: false,
  ),
);
```

2. **Language Change**
```dart
// Use UI-only restart to apply new locale
await TerminateRestart.instance.restartApp(
  options: TerminateRestartOptions(
    terminate: false,
  ),
);
```

3. **User Logout**
```dart
// Full restart with data clearing
await TerminateRestart.instance.restartApp(
  options: TerminateRestartOptions(
    terminate: true,
    clearData: true,
    preserveKeychain: true,  // Keep secure data
  ),
);
```

4. **App Update**
```dart
// Full restart to apply updates
await TerminateRestart.instance.restartApp(
  options: TerminateRestartOptions(
    terminate: true,
  ),
);
```

### Best Practices

1. **Choose the Right Mode**
   - Use UI-only restart when maintaining connections is important
   - Use full restart when a clean slate is needed
   - Use data clearing when security is a concern

2. **Handle Root Reset**
   - Always implement the `onRootReset` callback
   - Clear navigation stacks
   - Reset global state
   - Update UI accordingly

3. **Error Handling**
```dart
try {
  await TerminateRestart.instance.restartApp(
    options: TerminateRestartOptions(
      terminate: false,
    ),
  );
} catch (e) {
  print('Restart failed: $e');
  // Handle failure
}
```

## 📱 Platform-Specific Notes

### Android
- Uses `Process.killProcess()` for clean termination
- Handles activity recreation properly
- Manages app data clearing through proper Android APIs
- Supports custom intent flags
- Handles task stack management

### iOS
- Implements clean process termination
- Handles UserDefaults and Keychain data preservation
- Manages view controller recreation for UI-only restarts
- Supports background task completion
- Handles state restoration

## 🔍 Common Use Cases

1. **After Dynamic Updates**
   ```dart
   // After downloading new assets/code
   await TerminateRestart.instance.restartApp(
     options: TerminateRestartOptions(
       terminate: true,
       mode: RestartMode.withConfirmation,
       dialogTitle: 'Update Ready',
       dialogMessage: 'Restart to apply updates?',
     ),
   );
   ```

2. **Clearing Cache**
   ```dart
   // Clear app data but preserve important settings
   await TerminateRestart.instance.restartApp(
     options: TerminateRestartOptions(
       terminate: true,
       clearData: true,
       preserveKeychain: true,
       preserveUserDefaults: true,
     ),
   );
   ```

3. **Quick UI Refresh**
   ```dart
   // Refresh UI without full restart
   await TerminateRestart.instance.restartApp(
     options: TerminateRestartOptions(
       terminate: false,
     ),
   );
   ```

## 📊 Performance Metrics

| Operation | Average Time |
|-----------|-------------|
| UI-only Restart | ~300ms |
| Full Termination | ~800ms |
| Data Clearing | ~200ms |
| With Dialog | +100ms |

## 🔐 Security Considerations

1. **Sensitive Data**
   - Use `preserveKeychain` for credentials
   - Clear data on logout
   - Handle biometric authentication state

2. **State Management**
   - Clear sensitive state before restart
   - Handle authentication tokens properly
   - Manage secure storage access

3. **Platform Security**
   - Proper permission handling
   - Secure data clearing
   - Protected file access

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Special thanks to:
- The Flutter team for the amazing framework
- All contributors who helped improve this plugin
- The community for valuable feedback and suggestions

## 📞 Support

If you have any questions or need help, you can:
- Open an [issue](https://github.com/sleem2012/terminate_restart/issues)
- Check our [example app](example) for more usage examples
- Read our [API documentation](https://pub.dev/documentation/terminate_restart/latest/)

## 📚 Complete Example

Check out our [example app](example) for a full demonstration of all features, including:

- Basic UI/Process restart
- Data clearing with preservation options
- Custom confirmation dialogs
- Error handling
- State management
- Platform-specific features

## 🎥 Demo

### Quick Preview
![Demo](screenshots/demo.gif)

### Video Tutorial
https://github.com/sleem2012/terminate_restart/assets/video/demo.mp4

<video width="320" height="240" controls>
  <source src="https://github.com/sleem2012/terminate_restart/assets/video/demo.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

## 📱 Screenshots

<div style="display: flex; flex-direction: row;">
  <img src="screenshots/basic.png" width="250" alt="Basic Usage">
  <img src="screenshots/dialog.png" width="250" alt="Confirmation Dialog">
  <img src="screenshots/data_clearing.png" width="250" alt="Data Clearing">
</div>

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

### iOS Implementation

The iOS implementation provides:

- Clean process termination
- State preservation options
- Keychain data handling
- User defaults management

## 👨‍💻 Author

Made with ❤️ by Ahmed Sleem
[LinkedIn](https://www.linkedin.com/in/sleem98/) • [GitHub](https://github.com/sleem2012/terminate_restart) • [pub.dev](https://pub.dev/packages/terminate_restart)

---

<p align="center">
  <a href="https://github.com/sleem2012/terminate_restart">GitHub</a> •
  <a href="https://pub.dev/packages/terminate_restart">pub.dev</a> •
  <a href="https://github.com/sleem2012/terminate_restart/issues">Issues</a>
</p>

## 🎯 Real-World Examples

### 1. Theme Switching

```dart
class ThemeManager {
  static Future<void> switchTheme() async {
    // Save new theme
    await prefs.setString('theme', 'dark');
    
    // Restart UI only to apply theme
    await TerminateRestart.instance.restartApp(
      options: TerminateRestartOptions(
        terminate: false,
      ),
    );
  }
}
```

### 2. Language Change

```dart
class LocalizationManager {
  static Future<void> changeLanguage(String locale) async {
    // Save new locale
    await prefs.setString('locale', locale);
    
    // Show confirmation with custom message
    await TerminateRestart.instance.restartApp(
      options: TerminateRestartOptions(
        terminate: true,
        mode: RestartMode.withConfirmation,
        dialogTitle: 'Language Changed',
        dialogMessage: 'Restart app to apply new language?',
        restartNowText: 'Restart Now',
        restartLaterText: 'Later',
      ),
    );
  }
}
```

### 3. App Update

```dart
class UpdateManager {
  static Future<void> applyUpdate() async {
    try {
      // Download and save update
      await downloadUpdate();
      
      // Clear cache but preserve settings
      await TerminateRestart.instance.restartApp(
        options: TerminateRestartOptions(
          terminate: true,
          mode: RestartMode.withConfirmation,
          clearData: true,
          preserveUserDefaults: true,
          preserveKeychain: true,
          dialogTitle: 'Update Ready',
          dialogMessage: 'Restart to complete update?',
        ),
      );
    } catch (e) {
      print('Update failed: $e');
    }
  }
}
```

### 4. User Logout

```dart
class AuthManager {
  static Future<void> logout() async {
    try {
      // Clear all data except keychain
      await TerminateRestart.instance.restartApp(
        options: TerminateRestartOptions(
          clearData: true,
          preserveKeychain: true,
          terminate: true, // Full restart for security
        ),
      );
    } catch (e) {
      print('Logout failed: $e');
    }
  }
}
```

## 🔧 Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `context` | `BuildContext?` | `null` | Required for confirmation dialog |
| `mode` | `RestartMode` | `immediate` | Restart mode (immediate/confirmation) |
| `clearData` | `bool` | `false` | Clear app data during restart |
| `preserveKeychain` | `bool` | `false` | Keep keychain data when clearing |
| `preserveUserDefaults` | `bool` | `false` | Keep user defaults when clearing |
| `terminate` | `bool` | `true` | Full termination vs UI-only restart |

## 🛡️ Error Handling

### Common Errors and Solutions

1. **Context Error**
```dart
try {
  await TerminateRestart.instance.restartApp(
    options: TerminateRestartOptions(
      terminate: true,
      mode: RestartMode.withConfirmation,
    ),
  );
} on ArgumentError catch (e) {
  // Handle invalid or disposed context
  print('Context error: $e');
} catch (e) {
  print('Other error: $e');
}
```

2. **Data Clearing Error**
```dart
try {
  await TerminateRestart.instance.restartApp(
    options: TerminateRestartOptions(
      terminate: true,
      clearData: true,
      preserveKeychain: true,
    ),
  );
} on PlatformException catch (e) {
  // Handle platform-specific errors
  print('Platform error: $e');
} catch (e) {
  print('Other error: $e');
}
```

3. **Timeout Handling**
```dart
try {
  await TerminateRestart.instance.restartApp(
    options: TerminateRestartOptions(
      terminate: true,
    ),
  ).timeout(
    Duration(seconds: 5),
    onTimeout: () {
      throw TimeoutException('Restart timed out');
    },
  );
} on TimeoutException catch (e) {
  print('Timeout: $e');
}
```
