import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../terminate_restart_platform_interface.dart';

/// An implementation of [TerminateRestartPlatform] that uses method channels.
class MethodChannelTerminateRestart extends TerminateRestartPlatform {
  /// The method channel used to communicate with the native platform.
  final methodChannel = const MethodChannel('com.ahmedsleem.terminate_restart/restart');

  @override
  Future<bool> restartApp({
    bool clearData = false,
    bool preserveKeychain = false,
    bool preserveUserDefaults = false,
    bool terminate = true,
  }) async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'restartApp',
        {
          'clearData': clearData,
          'preserveKeychain': preserveKeychain,
          'preserveUserDefaults': preserveUserDefaults,
          'terminate': terminate,
        },
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint(' [TerminateRestart] Platform error: $e');
      return false;
    } catch (e) {
      debugPrint(' [TerminateRestart] General error: $e');
      return false;
    }
  }
}
