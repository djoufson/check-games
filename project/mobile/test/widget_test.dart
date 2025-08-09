import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CheckGameApp());

    // Allow the auth provider to initialize
    await tester.pumpAndSettle();

    // Verify that we can see login elements (since no user is authenticated)
    expect(find.text('Check Games'), findsOneWidget);
    expect(find.text('Welcome Back!'), findsOneWidget);
  });
}
