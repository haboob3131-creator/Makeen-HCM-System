import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/main_navigation_screen.dart';

class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  // كائن التحقق البيومتري من مكتبة local_auth
  final LocalAuthentication _auth = LocalAuthentication();

  // حالة التحقق الحالية، لتمنع تنفيذ أكثر من محاولة تحقق في نفس الوقت
  bool _isAuthenticating = false;

  // رسالة الحالة الحالية للواجهة، مثل: جاري التحقق، تم النجاح، أو فشل التحقق
  String _authStatus = 'جاري التحقق من البصمة...';

  // يتم تشغيل التحقق بشكل تلقائي عند فتح شاشة البصمة
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  // هذه الدالة تقوم بفحص دعم الجهاز للبصمة ثم تنفيذ التحقق البيومتري
  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _authStatus = 'جاري التحقق من البصمة...';
    });

    try {
      // التحقق من أن الجهاز يدعم البصمة أو أن قفل الشاشة مهيأ
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      final bool canAuthenticate = canAuthenticateWithBiometrics || isDeviceSupported;

      // إذا لم يدعم الجهاز البصمة أو لم يتم إعداد شاشة القفل، نوقف العملية
      if (!canAuthenticate) {
        if (!mounted) return;
        setState(() {
          _isAuthenticating = false;
          _authStatus = 'الجهاز لا يدعم التحقق من البصمة أو قفل الشاشة غير مهيأ.';
        });
        return;
      }

      // تنفيذ التحقق الفعلي للبصمة أو الوجه حسب الجهاز
      final bool authenticated = await _auth.authenticate(
        localizedReason: 'الرجاء التحقق من هويتك لتسجيل الدخول',
        biometricOnly: false,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );

      if (!mounted) return;
      setState(() {
        _isAuthenticating = false;
        _authStatus = authenticated ? 'تم التحقق بنجاح!' : 'فشل التحقق من البصمة';
      });

      // إذا نجح التحقق، يتم حفظ حالة الدخول المحلية داخل الهاتف
      if (authenticated) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('biometricLoginEnabled', true);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم التحقق بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _isAuthenticating = false;
        _authStatus = 'خطأ في البصمة: ${e.message ?? 'غير معروف'}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Text(
                'التحقق من البصمة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E293B),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                        blurRadius: 20,
                        spreadRadius: 10,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.fingerprint,
                    size: 90,
                    color: Color(0xFF00E5FF),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _authStatus,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _isAuthenticating ? null : _authenticate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF334155)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.fingerprint, color: Color(0xFF00E5FF)),
                label: Text(
                  _isAuthenticating ? 'جاري التحقق...' : 'التحقق من البصمة',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}