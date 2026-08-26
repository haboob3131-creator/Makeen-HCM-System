import 'package:flutter/material.dart';
import 'main_navigation_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('assets/logo.png'),
                width: 400,
                height: 400,
              ),
              const SizedBox(height: 16),
              const Text('تسجيل الدخول', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A5F7A))),
              const SizedBox(height: 40),
              const TextField(decoration: InputDecoration(labelText: 'الرقم الوظيفي', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              const TextField(obscureText: true, decoration: InputDecoration(labelText: 'كلمة المرور', border: OutlineInputBorder())),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF22A39F),
                ),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigationScreen()));
                },
                child: const Text('دخول', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              const SizedBox(height: 16),


TextButton(
  onPressed: () {
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  },
  child: const Text(
    'ليس لديك حساب؟ إنشاء حساب جديد',
    style: TextStyle(fontSize: 16, color: Color(0xFF1A5F7A), fontWeight: FontWeight.bold),
  ),
),
            ],
          ),
        ),
      ),
    );
  }
}