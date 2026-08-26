import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('خطة الزيارات اليومية'), backgroundColor: const Color(0xFF1A5F7A)),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.local_pharmacy, color: Color(0xFF22A39F)),
          title: Text('زيارة صيدلية رقم ${index + 1}'),
          subtitle: const Text('قيد الانتظار'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}