import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_project/pages/signup_screen.dart';
import 'package:my_project/pages/login_screen.dart';
import 'package:my_project/pages/main_navigation_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('device journey: signup, logout and login', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Device QA');
    await tester.enterText(fields.at(1), 'QA-DEVICE');
    await tester.enterText(fields.at(2), 'qa-device@example.test');
    await tester.enterText(fields.at(3), 'test-only-password-456');
    await tester.enterText(fields.at(4), 'test-only-password-456');
    await tester.tap(find.text('تسجيل'));
    await tester.pumpAndSettle();
    expect(find.byType(MainNavigationScreen), findsOneWidget);
    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تسجيل الخروج'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'qa-device@example.test');
    await tester.enterText(find.byType(TextField).at(1), 'test-only-password-456');
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(find.byType(MainNavigationScreen), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getBool('isLoggedIn'), isTrue);
  });
}
