import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lakshya_hostel_erp/main.dart';

void main() {
  testWidgets('App loads and shows Login Screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LakshyaHostelErpApp());

    // Verify that the login screen elements are shown.
    expect(find.text('Phone Number or Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In as Resident'), findsOneWidget);
  });
}

