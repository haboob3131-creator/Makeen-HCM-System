import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_project/pages/login_screen.dart';
import 'package:my_project/pages/signup_screen.dart';
import 'package:my_project/pages/main_navigation_screen.dart';
import 'package:my_project/pages/leave_request_screen.dart';
import 'package:my_project/pages/financial_request_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> fillSignup(WidgetTester tester, {String email = 'qa@example.test'}) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(5));
    await tester.enterText(fields.at(0), 'QA Employee');
    await tester.enterText(fields.at(1), 'QA-42');
    await tester.enterText(fields.at(2), email);
    await tester.enterText(fields.at(3), 'test-only-password-456');
    await tester.enterText(fields.at(4), 'test-only-password-456');
  }

  testWidgets('signup rejects empty fields', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));
    await tester.tap(find.text('تسجيل'));
    await tester.pump();
    expect(find.text('يرجى تعبئة جميع الحقول'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getStringList('registered_accounts'), isNull);
  });

  testWidgets('signup rejects mismatch', (tester) async {
    await fillSignup(tester);
    await tester.enterText(find.byType(TextField).at(4), 'other-password');
    await tester.tap(find.text('تسجيل'));
    await tester.pump();
    expect(find.text('كلمتي المرور غير متطابقتين!'), findsOneWidget);
  });

  testWidgets('signup rejects duplicate email regardless of case', (tester) async {
    SharedPreferences.setMockInitialValues({
      'registered_accounts': [jsonEncode({
        'name':'Existing','empId':'1','email':'qa@example.test','password':'test-only'
      })]
    });
    await fillSignup(tester, email:'QA@EXAMPLE.TEST');
    await tester.tap(find.text('تسجيل'));
    await tester.pump();
    expect(find.text('هذا البريد الإلكتروني مسجل بالفعل'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getStringList('registered_accounts'), hasLength(1));
  });

  testWidgets('valid signup writes local account and navigates', (tester) async {
    await fillSignup(tester);
    await tester.tap(find.text('تسجيل'));
    await tester.pumpAndSettle();
    expect(find.byType(MainNavigationScreen), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('isLoggedIn'), isTrue);
    final accounts = prefs.getStringList('registered_accounts')!;
    expect(accounts, hasLength(1));
    expect((jsonDecode(accounts.single) as Map<String, dynamic>)['empId'], 'QA-42');
  });

  testWidgets('login rejects empty credentials', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pump();
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pump();
    expect(find.text('يرجى إدخال البريد الإلكتروني وكلمة المرور'), findsOneWidget);
  });

  testWidgets('login rejects a wrong password', (tester) async {
    SharedPreferences.setMockInitialValues({
      'registered_accounts': [jsonEncode({
        'email':'qa@example.test','name':'QA','empId':'42','password':'correct'
      })]
    });
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(0), 'qa@example.test');
    await tester.enterText(find.byType(TextField).at(1), 'incorrect');
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pump();
    expect(find.textContaining('البريد الإلكتروني أو كلمة المرور غير صحيحة'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getBool('isLoggedIn'), isNot(true));
  });

  testWidgets('leave request rejects missing reason', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LeaveRequestScreen()));
    await tester.pump();
    await tester.tap(find.text('إرسال الطلب'));
    await tester.pump();
    expect(find.text('الرجاء كتابة سبب الإجازة'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getStringList('leave_requests'), isNull);
  });

  testWidgets('leave request persists pending status', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LeaveRequestScreen()));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'QA leave');
    await tester.tap(find.text('إرسال الطلب'));
    await tester.pump();
    final logs=(await SharedPreferences.getInstance()).getStringList('leave_requests')!;
    expect((jsonDecode(logs.single) as Map<String,dynamic>)['status'], 'قيد المراجعة');
  });

  testWidgets('financial request rejects missing amount and reason', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FinancialRequestScreen()));
    await tester.pump();
    await tester.tap(find.text('إرسال الطلب'));
    await tester.pump();
    expect(find.text('الرجاء إدخال المبلغ والغرض'), findsOneWidget);
  });

  testWidgets('financial request persists pending status', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FinancialRequestScreen()));
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(0), '1500');
    await tester.enterText(find.byType(TextField).at(1), 'QA purpose');
    await tester.tap(find.text('إرسال الطلب'));
    await tester.pump();
    final logs=(await SharedPreferences.getInstance()).getStringList('financial_requests')!;
    final data=jsonDecode(logs.single) as Map<String,dynamic>;
    expect(data['amount'], '1500');
    expect(data['status'], 'قيد المراجعة');
  });
}
