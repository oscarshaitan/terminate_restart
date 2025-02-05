import 'package:flutter/material.dart';
import '../terminate_restart_platform_interface.dart';

/// Enum to specify the restart mode
enum RestartMode {
  /// Restart immediately without showing a dialog
  immediate,

  /// Show a confirmation dialog before restarting
  withConfirmation,
}

/// The main plugin class for restarting Flutter apps
class TerminateRestart {
  /// Private constructor to prevent instantiation
  TerminateRestart._();

  /// The singleton instance of the plugin
  static final instance = TerminateRestart._();

  static const MethodChannel _channel =
      MethodChannel('com.ahmedsleem.terminate_restart/restart');
  
  static const MethodChannel _internalChannel =
      MethodChannel('com.ahmedsleem.terminate_restart/internal');
  
  static bool _initialized = false;
  static VoidCallback? _onRootReset;

  /// Initialize the plugin and set up internal handlers
  static void initialize({VoidCallback? onRootReset}) {
    if (!_initialized) {
      _onRootReset = onRootReset;
      _internalChannel.setMethodCallHandler(_handleInternalMessages);
      _initialized = true;
    }
  }

  static Future<dynamic> _handleInternalMessages(MethodCall call) async {
    switch (call.method) {
      case 'resetToRoot':
        _onRootReset?.call();
        break;
    }
  }

  /// Restarts the app with the given options.
  ///
  /// [context] is required when [mode] is [RestartMode.withConfirmation].
  /// [clearData] determines whether to clear app data during restart.
  /// [preserveKeychain] determines whether to keep keychain data when clearing.
  /// [preserveUserDefaults] determines whether to keep user defaults when clearing.
  /// [terminate] determines whether to do a full process termination vs UI refresh.
  /// [dialogTitle] is the title for the confirmation dialog.
  /// [dialogMessage] is the message for the confirmation dialog.
  /// [restartNowText] is the text for the restart now button.
  /// [restartLaterText] is the text for the restart later button.
  /// [cancelText] is the text for the cancel button.
  ///
  /// Returns true if the restart was successful, false otherwise.
  static Future<bool> restartApp({
    BuildContext? context,
    RestartMode mode = RestartMode.immediate,
    bool clearData = false,
    bool preserveKeychain = false,
    bool preserveUserDefaults = false,
    bool terminate = true,
    String? dialogTitle,
    String? dialogMessage,
    String? restartNowText,
    String? restartLaterText,
    String? cancelText,
  }) async {
    // Validate context when needed
    if (mode == RestartMode.withConfirmation &&
        (context == null || !context.mounted)) {
      throw ArgumentError(
        'context is required when mode is RestartMode.withConfirmation',
      );
    }

    // Show confirmation dialog if needed
    if (mode == RestartMode.withConfirmation && context != null) {
      final bool? shouldRestart = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(dialogTitle ?? 'Confirm Restart'),
          content: Text(dialogMessage ?? 'Do you want to restart the app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(restartLaterText ?? 'Later'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(restartNowText ?? 'Restart Now'),
            ),
          ],
        ),
      );

      // Return false if user cancelled or postponed
      if (shouldRestart != true) {
        return false;
      }
    }

    try {
      debugPrint('🔄 [TerminateRestart] Preparing for restart...');
      return await TerminateRestartPlatform.instance.restartApp(
        clearData: clearData,
        preserveKeychain: preserveKeychain,
        preserveUserDefaults: preserveUserDefaults,
        terminate: terminate,
      );
    } catch (e) {
      debugPrint('🔄 [TerminateRestart] Error restarting app: $e');
      rethrow;
    }
  }
}
