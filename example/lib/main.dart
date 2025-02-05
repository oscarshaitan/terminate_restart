import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terminate_restart/terminate_restart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Terminate Restart Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Terminate Restart Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool _clearData = false;
  bool _preserveKeychain = false;
  bool _preserveUserDefaults = false;
  bool _terminate = true;
  
  // Persistent data example
  int _persistentCounter = 0;
  String? _lastRestartTime;
  SharedPreferences? _prefsInstance;
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePrefs();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializePrefs() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      setState(() {
        _prefsInstance = prefs;
        _persistentCounter = prefs.getInt('counter') ?? 0;
        _lastRestartTime = prefs.getString('lastRestart');
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error initializing prefs: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _clearStoredData() async {
    if (_prefsInstance == null) return;
    
    try {
      await _prefsInstance!.clear();
    } catch (e) {
      debugPrint('Error clearing prefs: $e');
    }
  }

  Future<void> _incrementCounter() async {
    if (_prefsInstance == null) return;
    
    try {
      setState(() {
        _persistentCounter++;
      });
      
      await _prefsInstance!.setInt('counter', _persistentCounter);
    } catch (e) {
      debugPrint('Error incrementing counter: $e');
    }
  }

  String _getDataClearingMessage() {
    if (!_clearData) return '';
    final preserving = <String>[];
    if (_preserveKeychain) preserving.add('keychain');
    if (_preserveUserDefaults) preserving.add('user defaults');
    
    if (preserving.isEmpty) {
      return '\n\nAll app data will be cleared.';
    } else {
      return '\n\nApp data will be cleared except: ${preserving.join(' and ')}.';
    }
  }

  Future<void> _restartApp({
    required RestartMode mode,
    required String buttonLabel,
  }) async {
    if (!mounted) return;

    try {
      // Clear data first if requested
      if (_clearData) {
        await _clearStoredData();
      }

      // Show confirmation dialog if needed
      if (mode == RestartMode.withConfirmation) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Restart App'),
            content: Text('Are you sure you want to restart the app?${_getDataClearingMessage()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(buttonLabel),
              ),
            ],
          ),
        );

        if (confirmed != true) return;
      }

      // Restart the app
      if (!mounted) return;
      
      final result = await TerminateRestart.restartApp(
        context: mode == RestartMode.withConfirmation ? context : null,
        mode: mode,
        clearData: false, // We already cleared data if needed
        preserveKeychain: _preserveKeychain,
        preserveUserDefaults: _preserveUserDefaults,
        terminate: _terminate,
      );

      if (!result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to restart app')),
        );
      }
    } catch (e) {
      debugPrint('Error restarting app: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Terminate & Restart Example'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                // Persistent data example
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Persistent Data Example',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Counter: $_persistentCounter',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  if (_lastRestartTime != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Last Restart: $_lastRestartTime',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: _incrementCounter,
                              icon: const Icon(Icons.add),
                              label: const Text('Increment'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _preserveUserDefaults
                              ? 'Counter will be preserved on restart'
                              : 'Counter will be reset if data is cleared',
                          style: TextStyle(
                            fontSize: 12,
                            color: _preserveUserDefaults ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Data clearing options
                Card(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Data Options',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('Clear App Data'),
                        subtitle:
                            const Text('Clear app cache, files, and preferences'),
                        value: _clearData,
                        onChanged: (bool value) {
                          setState(() {
                            _clearData = value;
                            if (!value) {
                              _preserveKeychain = false;
                              _preserveUserDefaults = false;
                            }
                          });
                        },
                      ),
                      if (_clearData) ...[
                        const Divider(),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            'Preserve Options',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SwitchListTile(
                          title: const Text('Preserve Keychain'),
                          subtitle: const Text('Keep passwords and credentials'),
                          value: _preserveKeychain,
                          onChanged: (bool value) {
                            setState(() {
                              _preserveKeychain = value;
                            });
                          },
                        ),
                        SwitchListTile(
                          title: const Text('Preserve User Defaults'),
                          subtitle: const Text('Keep app preferences and settings'),
                          value: _preserveUserDefaults,
                          onChanged: (bool value) {
                            setState(() {
                              _preserveUserDefaults = value;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Restart buttons
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _restartApp(
                          mode: RestartMode.immediate,
                          buttonLabel: 'Terminate & Restart',
                        ),
                        icon: const Icon(Icons.power_settings_new),
                        label: const Text('Terminate & Restart'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          setState(() => _terminate = false);
                          _restartApp(
                            mode: RestartMode.immediate,
                            buttonLabel: 'Restart Only',
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Restart Only'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _restartApp(
                          mode: RestartMode.withConfirmation,
                          buttonLabel: 'Restart',
                        ),
                        icon: const Icon(Icons.help_outline),
                        label: const Text('Show Dialog Example'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
