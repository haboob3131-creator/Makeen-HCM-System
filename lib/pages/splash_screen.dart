import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../local_auth.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Timer يقوم بتأخير التحقق لبضع ثوانٍ حتى تظهر شاشة البداية
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    // بعد 3 ثوانٍ، يتم تحديد الصفحة المناسبة
    _navigationTimer = Timer(const Duration(seconds: 3), _checkLoginAndNavigate);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  // هذه الدالة تحدد الصفحة المناسبة عند فتح التطبيق
  Future<void> _checkLoginAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();

    // قراءة حالة الدخول الحالية من التخزين المحلي
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final biometricEnabled = prefs.getBool('biometricLoginEnabled') ?? false;
    final hasRealAccount = (prefs.getStringList('registered_accounts') ?? const <String>[]).isNotEmpty;

    if (mounted) {
      // إذا كان المستخدم قد سجل دخول فعليًا، انتقل إلى الصفحة الرئيسية
      if (isLoggedIn) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigationScreen()));
      }
      // إذا لم يكن مسجل دخول ولكن تم تفعيل البصمة وكان هناك حساب فعلي، انتقل إلى شاشة البصمة
      else if (biometricEnabled && hasRealAccount) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BiometricAuthScreen()));
      } else {
        // إذا لم توجد حالة دخول، يتم توجيه المستخدم إلى شاشة تسجيل الدخول
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Image(
              image: AssetImage('assets/logo.png'), // تأكد من وجود الشعار
              width: 300,
              height: 300,
            ),
            SizedBox(height: 60),
            CircularProgressIndicator(color: Color(0xFF22A39F)),
          ],
        ),
      ),
    );
  }
}