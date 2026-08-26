import 'package:flutter/material.dart';


class AttendanceLogScreen extends StatelessWidget {
  const AttendanceLogScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('السجل الزمني'), backgroundColor: const Color(0xFF1A5F7A)), 
      body: const Center(child: Text('سجل البصمات الخاص بك يظهر هنا'))
    );
  }
}