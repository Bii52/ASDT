import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app.dart';

void main() {
  testWidgets('WelcomePage shows title and buttons', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that the welcome page title is displayed.
    expect(find.text('Chăm Sóc Sức Khỏe'), findsOneWidget);

    // Verify that the login and register buttons are present.
    expect(find.widgetWithText(FilledButton, 'Đăng nhập'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Đăng ký'), findsOneWidget);
  });
}