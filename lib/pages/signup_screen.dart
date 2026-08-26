import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A5F7A),
        iconTheme: const IconThemeData(color: Colors.white), // لتلوين سهم الرجوع
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.person_add_alt_1, size: 80, color: Color(0xFF1A5F7A)),
              const SizedBox(height: 30),
              
              
              const TextField(decoration: InputDecoration(labelText: 'الاسم الرباعي', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: 'الرقم الوظيفي', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              const TextField(obscureText: true, decoration: InputDecoration(labelText: 'كلمة المرور', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              const TextField(obscureText: true, decoration: InputDecoration(labelText: 'تأكيد كلمة المرور', border: OutlineInputBorder())),
              const SizedBox(height: 32),
              
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF22A39F),
                ),
                onPressed: () {
                  
                },
                child: const Text('تسجيل', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}