import 'package:flutter/material.dart';

// Generated environment configuration
import 'config/env.g.dart';

void main() {
  // Initialize environment
  AppConfig.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Env Gen Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Environment Configuration'),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Environment Configuration',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'Configuration Values:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const ConfigExample(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ConfigExample extends StatelessWidget {
  const ConfigExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the generated config
    final apiUrl = AppConfig.apiBaseUrl;
    final appName = AppConfig.appName;
    final enableLogs = AppConfig.enableLogs;
    final cacheTimeout = AppConfig.cacheTimeout;
    final supportedLocales = AppConfig.supportedLocales;
    final currentEnv = AppConfig.currentEnvironment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• API URL: $apiUrl'),
        Text('• App Name: $appName'),
        Text('• Enable Logs: $enableLogs'),
        Text('• Cache Timeout: $cacheTimeout seconds'),
        Text('• Max Retry: ${AppConfig.maxRetryAttempts}'),
        Text('• Locales: ${supportedLocales.join(', ')}'),
        Text('• Dark Mode: ${AppConfig.featureDarkMode}'),
        Text('• Push Notifications: ${AppConfig.featurePushNotifications}'),
        Text('• DB Host: ${AppConfig.dbHost}'),
        Text('• DB Port: ${AppConfig.dbPort}'),
        Text('• DB Name: ${AppConfig.dbName}'),
        const SizedBox(height: 8),
        Text(
          'Current Environment: $currentEnv',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        const Text(
          'Note: Sensitive keys (API_KEY, JWT_SECRET) are obfuscated',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}