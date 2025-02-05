## 0.0.1

Initial release with the following features:

* Complete app termination and restart functionality
* Platform-specific implementations for Android and iOS
* Extensive customization options
* Perfect integration with Shorebird and other dynamic update systems
* App data management options
* Fast and reliable operation
* Comprehensive documentation and examples

### Features

* Proper process termination and restart on both platforms
* Customizable confirmation dialogs
* Timeout handling with fallback messages
* Data clearing options with granular control
* Platform-specific flags and options
* Comprehensive error handling and reporting
* Type-safe API with proper null safety

### Android Features

* Process.killProcess() for proper termination
* Configurable Intent flags
* Activity lifecycle management
* App data clearing options
* Proper error handling and logging

### iOS Features

* Clean process termination
* Configurable exit codes
* UserDefaults preservation options
* Keychain management
* Cache and temp file clearing

## 1.0.0

* Initial release with the following features:
  * Support for both Android and iOS platforms
  * Two restart modes: UI-only and full process termination
  * Optional data clearing during restart
  * Configurable data preservation options (keychain, user defaults)
  * Confirmation dialog support with customizable messages
  * Comprehensive example app demonstrating all features
  * Fixed data clearing functionality in both UI and terminate modes
  * Added extensive error handling and logging
  * Added type-safe API with null safety support

### Features
- Full app restart functionality
- UI-only refresh option
- Data clearing with selective preservation
- Extensive customization options
- Cross-platform support (Android & iOS)
- Comprehensive logging
- Type-safe implementation

### Android Implementation
- Proper process termination
- Activity/task management
- Intent flag handling
- State preservation options

### iOS Implementation
- Clean process termination
- State restoration
- Data management
- Background task handling

### Documentation
- Comprehensive README
- API documentation
- Usage examples
- Common issues & solutions

## 1.0.3

### 🚀 New Features
- Improved UI-only restart functionality:
  - Maintains WebSocket and HTTP connections
  - Properly resets to root state
  - Smooth transition animations
  - Added `initialize` method with `onRootReset` callback
- Better platform-specific implementations:
  - iOS: Uses proper view controller transitions
  - Android: Maintains Flutter engine while resetting activity

### 🛠️ Improvements
- Added comprehensive documentation
- Added comparison of restart modes
- Added best practices guide
- Improved error handling
- Added example code for common use cases

### 🐛 Bug Fixes
- Fixed UI-only restart not properly resetting to root
- Fixed Android activity recreation issues
- Fixed iOS view controller transition glitches

## 1.0.4

* Added `TerminateRestart.instance` singleton pattern for better state management
* Enhanced initialization with comprehensive state reset examples
* Added support for different state management solutions (GetX, Provider, Bloc)
* Improved documentation with real-world examples
* Updated all code examples to use the new instance pattern
* Fixed UI-only restart implementation
* Added proper error handling for timeouts and platform-specific errors

* Enhanced Android restart functionality:
  * Using `makeRestartActivityTask` for more reliable app restart
  * Improved activity recreation and state management
  * Better handling of process termination

* Improved iOS implementation:
  * Better URL scheme handling for app restart
  * Enhanced view controller management
  * Proper state preservation during restarts

* General improvements:
  * More reliable UI-only restart on both platforms
  * Better error handling and logging
  * Code cleanup and documentation updates
