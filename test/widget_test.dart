// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healthy_fitness/main.dart';
import 'package:healthy_fitness/screens/home/fitness_home_page.dart';

void main() {
  testWidgets('Fitness home page renders key sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const FitnessApp(home: FitnessHomePage()),
    );

    expect(find.text('Healthy Fitness'), findsWidgets);
    expect(find.text('Today\'s Goal'), findsOneWidget);
    expect(find.text('Quick Workouts'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Group Live Class'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();

    expect(find.text('Live Training Modes'), findsOneWidget);
    expect(find.text('1:1 Personal Session'), findsOneWidget);
    expect(find.text('Group Live Class'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
  });
}
