import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي'), backgroundColor: const Color(0xFF1A5F7A)), 
      body: Column(
        children: [
          const SizedBox(height: 40),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF22A39F),
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text('اسم المستخدم', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('مندوب مبيعات', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const Spacer(),
          const Text('نظام مَكِين لإدارة رأس المال البشري', style: TextStyle(color: Colors.grey)),
          const Text('إشراف: د. عادل الحاج', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
        ],
      )
    );
  }
}