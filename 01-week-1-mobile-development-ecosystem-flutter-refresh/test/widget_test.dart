import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_app/main.dart';

void main() {
  testWidgets('Profil Mahasiswa UI verification test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that AppBar title is 'Profil Mahasiswa'.
    expect(find.text('Profil Mahasiswa'), findsOneWidget);

    // Verify that Student Name is displayed.
    expect(find.text('Ghazwan Ababil'), findsOneWidget);

    // Verify that Student NIM is displayed.
    expect(find.text('244107020151'), findsOneWidget);

    // Verify that Campus Name is displayed.
    expect(find.text('Politeknik Negeri Malang'), findsOneWidget);

    // Verify that Course / Semester subtitle is displayed.
    expect(find.text('Pemrograman Mobile — Minggu 1'), findsOneWidget);

    // Verify that school icon is present.
    expect(find.byIcon(Icons.school), findsOneWidget);
  });
}
