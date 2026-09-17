import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تم إيقاف فايربيس للعمل محلياً
  runApp(const MakeenApp());
}

class MakeenApp extends StatelessWidget {
  const MakeenApp({super.key});

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