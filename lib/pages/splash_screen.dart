import 'package:flutter/material.dart';
import 'dart:async';
import 'package:local_auth/local_auth.dart';
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
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(seconds: 3), _checkLoginAndNavigate);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkLoginAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final biometricEnabled = prefs.getBool('biometricLoginEnabled') ?? false;

    if (mounted) {
      if (isLoggedIn) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigationScreen()));
      } else if (biometricEnabled) {
        final localAuth = LocalAuthentication();
        final canUseBiometrics = await localAuth.canCheckBiometrics;
        final isSupported = await localAuth.isDeviceSupported();

        if (canUseBiometrics || isSupported) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BiometricAuthScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
        }
      } else {
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