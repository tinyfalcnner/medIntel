import 'package:flutter/material.dart';
import 'app_layout.dart';

void main() {
  runApp(const MedIntelApp());
}

class MedIntelApp extends StatelessWidget {
  const MedIntelApp({super.key}); // use_super_parameters fixed

  @override
  Widget build(BuildContext context) {
    final Map<String, WidgetBuilder> appRoutes = {
      '/': (context) => const AppLayout(
            currentPageName: 'Home',
            child: Scaffold(
              body: Center(child: Text('Home Page')),
            ),
          ),
    };

    return MaterialApp(
      title: 'MedIntel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
