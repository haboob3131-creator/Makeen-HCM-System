import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات'), backgroundColor: const Color(0xFF1A5F7A)), 
      body: const Center(child: Text('لا توجد إشعارات جديدة حالياً'))
    );
  }
}