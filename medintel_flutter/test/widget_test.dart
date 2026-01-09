import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import your actual app entry point.
// This assumes lib/main.dart defines a MyApp widget or you can
// replace MyApp below with whatever your root widget is.
import 'package:medintel_flutter/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MyApp());

    // Simple sanity check: at least one widget is found
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
