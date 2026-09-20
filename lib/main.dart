import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';

// نقطة الدخول الرئيسية للتطبيق
// هنا يتم تهيئة Flutter وتشغيل التطبيق بالكامل
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// التطبيق الرئيسي
// هذا Widget يحدد السمة العامة للتطبيق، الاتجاه العربي، والصفحة الابتدائية
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // بناء الجذر الرئيسي للتطبيق
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نظام مكين',
      theme: ThemeData(
        primaryColor: const Color(0xFF1A5F7A),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF1A5F7A),
          secondary: const Color(0xFF22A39F),
        ),
        fontFamily: 'Tahoma',
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}