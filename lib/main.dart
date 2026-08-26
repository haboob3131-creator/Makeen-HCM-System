import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


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