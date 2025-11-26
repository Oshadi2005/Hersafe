import 'package:flutter_test/flutter_test.dart';
import 'package:hersafe_sprint1/main.dart'; // only import what you need

void main() {
  testWidgets('HerSafeApp starts on WelcomeScreen',
      (WidgetTester tester) async {
    // Launch the app
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Check for text that exists on WelcomeScreen
    expect(find.text('Welcome to HerSafe'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);

    // Tap Login and check navigation to LoginScreen
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Hi! Welcome'), findsOneWidget);

    // Tap Register and check navigation to RegisterScreen
    await tester.pageBack(); // go back to WelcomeScreen
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.text('Create Account'), findsOneWidget);
  });
}
