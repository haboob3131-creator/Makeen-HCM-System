import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // 1. تأكيد تهيئة المحرك الأساسي لفلاتر قبل تشغيل أي خدمات خارجية
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. تهيئة الاتصال بسيرفرات فايربيس السحابية
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 3. تشغيل التطبيق
  runApp(const MakeenApp());
}
class MakeenApp extends StatelessWidget {
  const MakeenApp({Key? key}) : super(key: key);

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
      home: const SplashScreen(), // أول واجهة تظهر
    );
  }
}