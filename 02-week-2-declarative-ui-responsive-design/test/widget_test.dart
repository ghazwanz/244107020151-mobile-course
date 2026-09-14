import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:responsive_layout/main.dart';

void main() {
  testWidgets('ProfileCard UI verification test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProfileApp());

    // Verify student profile details
    expect(find.text('Nama Mahasiswa'), findsOneWidget);
    expect(find.text('Ghazwan Ababil'), findsOneWidget);
    expect(find.text('NIM'), findsOneWidget);
    expect(find.text('244107020151'), findsOneWidget);
    expect(find.text('Kelas'), findsOneWidget);
    expect(find.text('TI-3E'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('ababilghazwan@gmail.com'), findsOneWidget);

    // Verify avatar icon
    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
