import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // حقول إنشاء الحساب الجديدة
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _empIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // هذه الدالة تنفذ إنشاء الحساب وتخزينه في الهاتف محليًا
  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final empId = _empIdController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // التحقق من تعبئة جميع الحقول قبل إنشاء الحساب
    if (name.isEmpty || empId.isEmpty || email.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة جميع الحقول'), backgroundColor: Colors.red),
      );
      return;
    }

    if (!email.contains('@')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال بريد إلكتروني صحيح'), backgroundColor: Colors.red),
      );
      return;
    }

    if (password.length < 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب أن تكون كلمة المرور 6 أحرف على الأقل'), backgroundColor: Colors.red),
      );
      return;
    }

    if (password != confirmPassword) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمتي المرور غير متطابقتين!'), backgroundColor: Colors.red),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // قراءة قائمة الحسابات المسجلة الحالية من التخزين المحلي
    final savedAccounts = prefs.getStringList('registered_accounts') ?? <String>[];
    final hasExistingAccount = savedAccounts.any((entry) {
      final decoded = jsonDecode(entry) as Map<String, dynamic>;
      return (decoded['email'] as String? ?? '').toLowerCase() == email.toLowerCase();
    });

    if (hasExistingAccount) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هذا البريد الإلكتروني مسجل بالفعل'), backgroundColor: Colors.orange),
      );
      return;
    }

    // بناء كائن الحساب الجديد
    final newAccount = {
      'name': name,
      'empId': empId,
      'email': email.toLowerCase(),
      'password': password,
    };

    // حفظ الحساب داخل قائمة الحسابات المسجلة محليًا
    savedAccounts.add(jsonEncode(newAccount));
    await prefs.setStringList('registered_accounts', savedAccounts);
    await prefs.setBool('isLoggedIn', true);
    await prefs.setBool('biometricLoginEnabled', false);
    await prefs.setString('emp_name', name);
    await prefs.setString('emp_id', empId);
    await prefs.setString('logged_in_email', email.toLowerCase());

    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainNavigationScreen()), (_) => false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _empIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب جديد', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1A5F7A), iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add_alt_1, size: 80, color: Color(0xFF1A5F7A)),
              const SizedBox(height: 30),
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'الاسم الرباعي', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _empIdController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الرقم الوظيفي', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'البريد الإلكتروني', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _confirmPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور', border: OutlineInputBorder())),
              const SizedBox(height: 32),
              ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: const Color(0xFF22A39F)), onPressed: _signUp, child: const Text('تسجيل', style: TextStyle(fontSize: 18, color: Colors.white))),
            ],
          ),
        ),
      ),
    );
  }
}