import 'package:flutter/material.dart';
import 'providers/notification_provider.dart';
import 'theme/app_theme.dart';
import 'views/home_screen.dart';

void main() {
  runApp(const NotificationHubApp());
}

class NotificationHubApp extends StatefulWidget {
  const NotificationHubApp({super.key});

  @override
  State<NotificationHubApp> createState() => _NotificationHubAppState();
}

class _NotificationHubAppState extends State<NotificationHubApp> {
  late final NotificationProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = NotificationProvider();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, child) {
        return MaterialApp(
          title: 'Notification Hub',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: HomeScreen(provider: _provider),
        );
      },
    );
  }
}
