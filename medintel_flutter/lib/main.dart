import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'app_layout.dart';
import 'widgets/home_dashboard.dart';
import 'screens/login_screen.dart';
import 'screens/exercise_diet_page.dart';
import 'screens/health_topics_page.dart';
import 'screens/user_profile_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedIntel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginScreen(), // start at fake login
      routes: {
        '/home': (_) => const AppLayout(
              currentPageName: 'Home',
              child: HomeDashboard(),
            ),
        '/health_topics': (_) => const AppLayout(
              currentPageName: 'Health Topics',
              child: HealthTopicsPage(),
            ),
        '/user_profile': (_) => const AppLayout(
              currentPageName: 'User Profile',
              child: UserProfilePage(),
            ),
        '/exercise_diet': (_) => const AppLayout(
              currentPageName: 'Exercise & Diet',
              child: ExerciseDietPage(),
            ),
      },
    );
  }
}
