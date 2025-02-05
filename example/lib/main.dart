import 'package:flutter/material.dart';
import 'package:terminate_restart/terminate_restart.dart';

void main() {
  // Initialize the plugin with root reset handler
  TerminateRestart.initialize(
    onRootReset: () {
      // This will be called during UI-only restarts
      // Reset your navigation to root
      // Clear navigation history
      // Reset any global state
    },
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Terminate Restart Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isDarkMode = false;

  void _toggleTheme() async {
    setState(() => _isDarkMode = !_isDarkMode);
    
    // Use UI-only restart to apply theme change
    await TerminateRestart.restartApp(
      options: TerminateRestartOptions(
        terminate: false, // UI-only restart
      ),
    );
  }

  void _simulateLogout() async {
    // Use full restart with data clearing for logout
    await TerminateRestart.restartApp(
      options: TerminateRestartOptions(
        terminate: true, // Full restart
        clearData: true,
        preserveKeychain: true, // Keep credentials
      ),
    );
  }

  void _simulateUpdate() async {
    // Use UI-only restart for smooth update
    await TerminateRestart.restartApp(
      options: TerminateRestartOptions(
        terminate: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminate Restart Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _toggleTheme,
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              label: Text(_isDarkMode ? 'Light Mode' : 'Dark Mode'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _simulateLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Simulate Logout'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _simulateUpdate,
              icon: const Icon(Icons.system_update),
              label: const Text('Simulate Update'),
            ),
          ],
        ),
      ),
    );
  }
}
