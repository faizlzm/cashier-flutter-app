/// Widget tests for Cashier Flutter App
///
/// This file contains basic widget tests to verify the app structure.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cashier_flutter_app/app.dart';

void main() {
  testWidgets('CashierApp renders splash screen', (WidgetTester tester) async {
    // Build our app with ProviderScope (required for Riverpod)
    await tester.pumpWidget(const ProviderScope(child: CashierApp()));

    // Pump a frame to render the splash screen (before auth initialization)
    await tester.pump();

    // Verify splash screen elements are present
    // The splash shows a CircularProgressIndicator while loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Kasir Pro'), findsOneWidget);
    expect(find.byIcon(Icons.point_of_sale_rounded), findsOneWidget);
  });
}
