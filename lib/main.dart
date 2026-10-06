import 'package:flutter/material.dart';
import 'features/notifications/notification_service.dart';
import 'screens/location_search_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().init();
  await NotificationService().init();
  runApp(const TravelApp());
}

class TravelApp extends StatelessWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthService().isLoggedIn();

    return MaterialApp(
      title: 'Travel Time',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: isLoggedIn ? const LocationSearchScreen() : const LoginScreen(),
    );
  }
}
