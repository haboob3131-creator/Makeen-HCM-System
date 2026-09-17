import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _empIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _signUp() async {
    if (_nameController.text.isEmpty || _empIdController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى تعبئة جميع الحقول'), backgroundColor: Colors.red));
      return;
    }
    
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كلمتي المرور غير متطابقتين!'), backgroundColor: Colors.red));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('emp_name', _nameController.text);
    await prefs.setString('emp_id', _empIdController.text);

    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainNavigationScreen()), (_) => false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _empIdController.dispose();
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