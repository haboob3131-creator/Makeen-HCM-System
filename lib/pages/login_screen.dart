import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إدخال البيانات'), backgroundColor: Colors.red));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigationScreen()));
    }
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
              const SizedBox(height: 30),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22A39F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: _login, child: const Text('تسجيل الدخول', style: TextStyle(fontSize: 18, color: Colors.white)))),
              const SizedBox(height: 20),
              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())), child: const Text('ليس لديك حساب؟ إنشاء حساب جديد', style: TextStyle(color: Color(0xFF1A5F7A), fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
    );
  }
}