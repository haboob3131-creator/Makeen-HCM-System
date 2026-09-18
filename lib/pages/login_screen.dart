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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricPreference();
  }

  Future<void> _loadBiometricPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _biometricEnabled = prefs.getBool('biometricLoginEnabled') ?? false;
      });
    }
  }

  Future<void> _saveBiometricPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometricLoginEnabled', value);
    if (mounted) {
      setState(() {
        _biometricEnabled = value;
      });
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إدخال البيانات'), backgroundColor: Colors.red));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setBool('biometricLoginEnabled', _biometricEnabled);

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
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                value: _biometricEnabled,
                onChanged: _saveBiometricPreference,
                title: const Text('تفعيل تسجيل الدخول بالبصمة', style: TextStyle(fontSize: 15, color: Color(0xFF1A5F7A))),
                contentPadding: EdgeInsets.zero,
                activeColor: Color(0xFF22A39F),
              ),
              const SizedBox(height: 22),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22A39F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: _login, child: const Text('تسجيل الدخول', style: TextStyle(fontSize: 18, color: Colors.white)))),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final localAuth = LocalAuthentication();
                    final canUseBiometrics = await localAuth.canCheckBiometrics;
                    final isSupported = await localAuth.isDeviceSupported();

                    if (!canUseBiometrics && !isSupported) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('الجهاز لا يدعم البصمة أو لم يتم تفعيل قفل الشاشة.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BiometricAuthScreen()),
                    );
                  },
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