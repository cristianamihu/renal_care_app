import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:renal_care_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app launches', (WidgetTester tester) async {
    // pornește aplicația
    app.main();
    await tester.pumpAndSettle();

    // verifică dacă un widget din ecranul principal apare
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
