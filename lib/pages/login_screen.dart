import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../local_auth.dart';
import 'main_navigation_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // حقل البريد الإلكتروني الخاص بالدخول عبر الحساب
  final TextEditingController _emailController = TextEditingController();

  // حقل كلمة المرور
  final TextEditingController _passwordController = TextEditingController();

  // متغير يحدد ما إذا كان المستخدم قد قام بتفعيل تسجيل الدخول بالبصمة أم لا
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    // جلب إعداد البصمة المحفوظ داخل الهاتف عند فتح شاشة تسجيل الدخول
    _loadBiometricPreference();
  }

  // قراءة قيمة تفعيل البصمة من التخزين المحلي
  Future<void> _loadBiometricPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _biometricEnabled = prefs.getBool('biometricLoginEnabled') ?? false;
      });
    }
  }

  // حفظ خيار تفعيل البصمة داخل الهاتف
  Future<void> _saveBiometricPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometricLoginEnabled', value);
    if (mounted) {
      setState(() {
        _biometricEnabled = value;
      });
    }
  }

  // تسجيل الدخول عبر البريد الإلكتروني وكلمة المرور
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال البريد الإلكتروني وكلمة المرور'), backgroundColor: Colors.red),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // قراءة جميع الحسابات المسجلة المحفوظة داخل الهاتف
    final rawAccounts = prefs.getStringList('registered_accounts') ?? <String>[];
    final registeredAccounts = rawAccounts
        .map((entry) => jsonDecode(entry) as Map<String, dynamic>)
        .toList();

    // البحث عن حساب مطابق للبريد الإلكتروني وكلمة المرور
    final account = registeredAccounts.firstWhere(
      (item) =>
          (item['email'] as String? ?? '').toLowerCase() == email.toLowerCase() &&
          (item['password'] as String? ?? '') == password,
      orElse: () => <String, dynamic>{},
    );

    // إذا لم يوجد حساب مطابق، نرفض الدخول
    if (account.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('البريد الإلكتروني أو كلمة المرور غير صحيحة. يجب إنشاء حساب فعلي أولاً.'), backgroundColor: Colors.red),
      );
      return;
    }

    // إذا تم التحقق، نحدد أن المستخدم مسجل دخول الآن
    await prefs.setBool('isLoggedIn', true);
    await prefs.setBool('biometricLoginEnabled', _biometricEnabled);
    await prefs.setString('emp_name', (account['name'] as String?) ?? '');
    await prefs.setString('emp_id', (account['empId'] as String?) ?? '');
    await prefs.setString('logged_in_email', (account['email'] as String?) ?? '');

    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigationScreen()));
    }
  }

  // فتح شاشة البصمة فقط بعد التأكد أن المستخدم لديه حساب فعلي مسجل
  Future<void> _openBiometricLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final hasRealAccount = (prefs.getStringList('registered_accounts') ?? const <String>[]).isNotEmpty;

    // منع الدخول بالبصمة إذا لم يكن هناك حساب فعلي موجود
    if (!hasRealAccount) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب إنشاء حساب فعلي أولاً قبل استخدام البصمة'), backgroundColor: Colors.orange),
      );
      return;
    }

    final localAuth = LocalAuthentication();
    final canUseBiometrics = await localAuth.canCheckBiometrics;
    final isSupported = await localAuth.isDeviceSupported();

    if (!canUseBiometrics && !isSupported) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الجهاز لا يدعم البصمة أو لم يتم تفعيل قفل الشاشة.'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BiometricAuthScreen()),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Image.asset('assets/logo.png', width: 120, height: 120),
              const SizedBox(height: 20),
              const Text('نظام مَكِين - SabaPharma', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A5F7A))),
              const SizedBox(height: 40),
              TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: 'البريد الإلكتروني', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.email, color: Color(0xFF1A5F7A)))),
              const SizedBox(height: 16),
              TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: 'كلمة المرور', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.lock, color: Color(0xFF1A5F7A)))),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                value: _biometricEnabled,
                onChanged: _saveBiometricPreference,
                title: const Text('تفعيل تسجيل الدخول بالبصمة', style: TextStyle(fontSize: 15, color: Color(0xFF1A5F7A))),
                contentPadding: EdgeInsets.zero,
                activeThumbColor: const Color(0xFF22A39F),
                activeTrackColor: const Color(0xFFBFEFEA),
              ),
              const SizedBox(height: 22),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22A39F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: _login, child: const Text('تسجيل الدخول', style: TextStyle(fontSize: 18, color: Colors.white)))),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _openBiometricLogin,
                  icon: const Icon(Icons.fingerprint, color: Color(0xFF1A5F7A)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1A5F7A)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  label: const Text('تسجيل الدخول بالبصمة', style: TextStyle(color: Color(0xFF1A5F7A), fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())), child: const Text('ليس لديك حساب؟ إنشاء حساب جديد', style: TextStyle(color: Color(0xFF1A5F7A), fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
    );
  }
}