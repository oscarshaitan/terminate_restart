import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminate_restart/terminate_restart.dart';
import 'package:terminate_restart/terminate_restart_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTerminateRestartPlatform with MockPlatformInterfaceMixin implements TerminateRestartPlatform {
  bool wasRestartCalled = false;
  bool shouldSucceed = true;
  Map<String, dynamic>? lastRestartArguments;

  @override
  Future<bool> restartApp({
    bool clearData = false,
    bool preserveKeychain = false,
    bool preserveUserDefaults = false,
    bool terminate = true,
  }) async {
    if (!shouldSucceed) {
      throw Exception('Mock platform error');
    }
    
    wasRestartCalled = true;
    lastRestartArguments = {
      'clearData': clearData,
      'preserveKeychain': preserveKeychain,
      'preserveUserDefaults': preserveUserDefaults,
      'terminate': terminate,
    };
    return shouldSucceed;
  }
}

void main() {
  late MockTerminateRestartPlatform mockPlatform;

  setUp(() {
    mockPlatform = MockTerminateRestartPlatform();
    TerminateRestartPlatform.instance = mockPlatform;
  });

  group('TerminateRestart', () {
    test('restartApp without dialog - default values', () async {
      mockPlatform.shouldSucceed = true;
      final success = await TerminateRestart.restartApp();

      expect(mockPlatform.wasRestartCalled, true);
      expect(mockPlatform.lastRestartArguments, {
        'clearData': false,
        'preserveKeychain': false,
        'preserveUserDefaults': false,
        'terminate': true,
      });
      expect(success, true);
    });

    test('restartApp without dialog - custom values', () async {
      mockPlatform.shouldSucceed = true;
      final success = await TerminateRestart.restartApp(
        clearData: true,
        preserveKeychain: true,
        preserveUserDefaults: true,
        terminate: false,
      );

      expect(mockPlatform.wasRestartCalled, true);
      expect(mockPlatform.lastRestartArguments, {
        'clearData': true,
        'preserveKeychain': true,
        'preserveUserDefaults': true,
        'terminate': false,
      });
      expect(success, true);
    });

    test('restartApp - platform returns false', () async {
      mockPlatform.shouldSucceed = false;
      
      expect(
        () => TerminateRestart.restartApp(),
        throwsA(isA<Exception>()),
      );
    });

    testWidgets('restartApp with dialog - user confirms', (tester) async {
      mockPlatform.shouldSucceed = true;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                await TerminateRestart.restartApp(
                  context: context,
                  mode: RestartMode.withConfirmation,
                  dialogTitle: 'Test Dialog',
                  dialogMessage: 'Test Message',
                  restartNowText: 'Now',
                  restartLaterText: 'Later',
                  cancelText: 'Cancel',
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Tap button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is shown with correct content
      expect(find.text('Test Dialog'), findsOneWidget);
      expect(find.text('Test Message'), findsOneWidget);
      expect(find.text('Now'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap 'Now' button
      await tester.tap(find.text('Now'));
      await tester.pumpAndSettle();

      // Verify platform method was called
      expect(mockPlatform.wasRestartCalled, true);
    });

    testWidgets('restartApp with dialog - user cancels', (tester) async {
      mockPlatform.shouldSucceed = true;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                await TerminateRestart.restartApp(
                  context: context,
                  mode: RestartMode.withConfirmation,
                  dialogTitle: 'Test Dialog',
                  dialogMessage: 'Test Message',
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Tap button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap 'Cancel' button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify platform method was not called
      expect(mockPlatform.wasRestartCalled, false);
    });

    testWidgets('restartApp with dialog - user postpones', (tester) async {
      mockPlatform.shouldSucceed = true;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                await TerminateRestart.restartApp(
                  context: context,
                  mode: RestartMode.withConfirmation,
                  dialogTitle: 'Test Dialog',
                  dialogMessage: 'Test Message',
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Tap button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap 'Later' button
      await tester.tap(find.text('Later'));
      await tester.pumpAndSettle();

      // Verify platform method was not called
      expect(mockPlatform.wasRestartCalled, false);
    });

    test('restartApp without context throws error for confirmation mode', () async {
      mockPlatform.shouldSucceed = true;
      expect(
        () => TerminateRestart.restartApp(
          mode: RestartMode.withConfirmation,
          dialogTitle: 'Test Dialog',
          dialogMessage: 'Test Message',
        ),
        throwsArgumentError,
      );
    });

    testWidgets('restartApp immediate mode ignores dialog options', (tester) async {
      mockPlatform.shouldSucceed = true;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                await TerminateRestart.restartApp(
                  context: context,
                  mode: RestartMode.immediate,
                  dialogTitle: 'Test Dialog',
                  dialogMessage: 'Test Message',
                );
              },
              child: const Text('Restart'),
            ),
          ),
        ),
      );

      // Tap restart button
      await tester.tap(find.text('Restart'));
      await tester.pumpAndSettle();

      // Verify no dialog is shown
      expect(find.text('Test Dialog'), findsNothing);
      expect(find.text('Test Message'), findsNothing);

      // Verify platform method was called immediately
      expect(mockPlatform.wasRestartCalled, true);
    });

    test('restartApp handles platform exceptions', () async {
      mockPlatform.shouldSucceed = false;
      
      expect(
        () => TerminateRestart.restartApp(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
