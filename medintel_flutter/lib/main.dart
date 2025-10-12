import 'package:flutter/material.dart';
import 'app_layout.dart';
import 'routes.dart';

void main() {
  runApp(MedIntelApp());
}

class MedIntelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
