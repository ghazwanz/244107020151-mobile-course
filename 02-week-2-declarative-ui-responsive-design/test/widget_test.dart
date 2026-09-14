import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:responsive_layout/main.dart';

void main() {
  testWidgets('DashboardApp UI verification test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DashboardApp());

    // Verify AppBar title
    expect(find.text('Student Dashboard'), findsOneWidget);

    // Verify Dashboard Cards
    expect(find.text('Assignments'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('92%'), findsOneWidget);
    expect(find.text('Portfolio'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Current week'), findsOneWidget);
    expect(find.text('02'), findsOneWidget);

    // Verify CupertinoSwitch and initial light mode icon
    expect(find.byType(CupertinoSwitch), findsOneWidget);
    expect(find.byIcon(Icons.light_mode), findsOneWidget);

    // Tap CupertinoSwitch to toggle theme
    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();

    // Verify theme icon changed to dark mode
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
  });
}
