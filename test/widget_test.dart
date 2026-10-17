import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_app/screens/auth/login_screen.dart';

void main() {
  testWidgets('login form validates required credentials', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Minimum 6 characters'), findsOneWidget);
  });

  testWidgets('forgot password asks for an email before sending a reset', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.text('Forgot password?'));
    await tester.pump();

    expect(find.text('Please enter your email above first'), findsOneWidget);
  });
}
