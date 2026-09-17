import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AttendanceLogScreen extends StatefulWidget {
  const AttendanceLogScreen({super.key});

  @override
  State<AttendanceLogScreen> createState() => _AttendanceLogScreenState();
}

class _AttendanceLogScreenState extends State<AttendanceLogScreen> {
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedLogs = prefs.getStringList('attendance_logs') ?? [];
    setState(() {
      _logs = savedLogs.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('السجل الزمني', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1A5F7A), iconTheme: const IconThemeData(color: Colors.white)),
      body: _logs.isEmpty
          ? const Center(child: Text('لا توجد سجلات حضور وانصراف بعد', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[_logs.length - 1 - index]; // لعرض الأحدث أولاً
                final isCheckIn = log['type'] == 'حضور';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCheckIn ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                      child: Icon(isCheckIn ? Icons.login : Icons.logout, color: isCheckIn ? Colors.green : Colors.red),
                    ),
                    title: Text('تسجيل ${log['type']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('الوقت: ${log['time']}\nالموقع: ${log['location']}'),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}