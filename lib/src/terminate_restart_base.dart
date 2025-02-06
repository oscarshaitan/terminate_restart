import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../terminate_restart_platform_interface.dart';

/// Options for restarting the app
class TerminateRestartOptions {
  /// Whether to terminate the app or just restart the UI
  final bool terminate;

  /// Whether to clear app data
  final bool clearData;

  /// Whether to preserve keychain data
  final bool preserveKeychain;

  /// Whether to preserve user defaults
  final bool preserveUserDefaults;

  /// Constructor
  const TerminateRestartOptions({
    this.terminate = true,
    this.clearData = false,
    this.preserveKeychain = false,
    this.preserveUserDefaults = false,
  });
}

/// Enum to specify the restart mode
enum RestartMode {
  /// Restart immediately without showing a dialog
  immediate,

  /// Show a confirmation dialog before restarting
  withConfirmation,
}

/// The main plugin class for restarting Flutter apps
class TerminateRestart {
  static TerminateRestart? _instance;

  /// Get the singleton instance
  static TerminateRestart get instance {
    _instance ??= TerminateRestart._();
    return _instance!;
  }

  /// Private constructor
  TerminateRestart._();

  final MethodChannel _internalChannel =
      const MethodChannel('com.ahmedsleem.terminate_restart/internal');

  bool _initialized = false;
  VoidCallback? _onRootReset;

  /// Initialize the plugin and set up internal handlers
  void initialize({VoidCallback? onRootReset}) {
    if (!_initialized) {
      _onRootReset = onRootReset;
      _internalChannel.setMethodCallHandler(_handleInternalMessages);
      _initialized = true;
    }
  }

  Future<dynamic> _handleInternalMessages(MethodCall call) async {
    switch (call.method) {
      case 'resetToRoot':
        if (_onRootReset != null) {
          _onRootReset!();
        } else {
          // Default behavior if no onRootReset callback is provided
          final rootElement = WidgetsBinding.instance.rootElement;
          if (rootElement != null) {
            // Find the first valid BuildContext
            BuildContext? context;
            void visitor(Element element) {
              if (!element.debugIsActive) return;
              context ??= element;
            }

            rootElement.visitChildren(visitor);

            if (context != null && context!.mounted) {
              // Get the navigator before any async operations
              final navigator = Navigator.of(context!, rootNavigator: true);

              // Reset navigation
              while (navigator.canPop()) {
                navigator.pop();
              }

              // Push to splash screen
              navigator.pushNamedAndRemoveUntil('/splash', (_) => false);
            }
          }
        }
        break;
    }
  }

  /// Restarts the app with the given options.
  Future<bool> restartApp({
    bool clearData = false,
    bool preserveKeychain = false,
    bool preserveUserDefaults = false,
    bool terminate = true,
  }) {
    return TerminateRestartPlatform.instance.restartApp(
      clearData: clearData,
      preserveKeychain: preserveKeychain,
      preserveUserDefaults: preserveUserDefaults,
      terminate: terminate,
    );
  }
}
