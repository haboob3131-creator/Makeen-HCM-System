import 'package:flutter/material.dart';


class ShiftScheduleScreen extends StatelessWidget {
  const ShiftScheduleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جدول الورديات'), backgroundColor: const Color(0xFF1A5F7A)), 
      body: const Center(child: Text('جدول مناوبات المصنع أو المكتب'))
    );
  }
}