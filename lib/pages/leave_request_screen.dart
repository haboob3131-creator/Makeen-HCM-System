import 'package:flutter/material.dart';

class LeaveRequestScreen extends StatelessWidget {
  const LeaveRequestScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلبات الإجازات'), backgroundColor: const Color(0xFF1A5F7A)), 
      body: const Center(child: Text('نموذج تقديم ومتابعة الإجازات'))
    );
  }
}