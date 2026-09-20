import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  // حقل سبب الإجازة
  final TextEditingController _reasonController = TextEditingController();

  // نوع الإجازة المختار
  String _selectedType = 'إجازة سنوية';

  // قائمة طلبات الإجازة السابقة
  List<Map<String, dynamic>> _myLeaves = [];

  // تهيئة الشاشة وتحميل طلبات الإجازة
  @override
  void initState() {
    super.initState();
    _loadLeaves(); 
  }

  // جلب طلبات الإجازة المحفوظة محليًا
  Future<void> _loadLeaves() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedLeaves = prefs.getStringList('leave_requests') ?? [];
    setState(() {
      _myLeaves = savedLeaves.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    });
  }

  // إرسال طلب إجازة جديد وتخزينه داخل الهاتف
  Future<void> _submitLeave() async {
    if (_reasonController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء كتابة سبب الإجازة'), backgroundColor: Colors.red));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    List<String> logs = prefs.getStringList('leave_requests') ?? [];

    final newLeave = {
      "type": _selectedType,
      "reason": _reasonController.text,
      "date": "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
      "status": "قيد المراجعة"
    };

    logs.add(jsonEncode(newLeave));
    await prefs.setStringList('leave_requests', logs);

    _reasonController.clear();
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    _loadLeaves();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب الإجازة بنجاح'), backgroundColor: Colors.green));
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // بناء واجهة طلبات الإجازات
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلبات الإجازات', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1A5F7A), iconTheme: const IconThemeData(color: Colors.white)), 
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('تقديم طلب جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A5F7A))),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    items: ['إجازة سنوية', 'إجازة مرضية', 'إجازة طارئة', 'إجازة بدون راتب'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                    onChanged: (val) => setState(() => _selectedType = val!),
                    decoration: InputDecoration(labelText: 'نوع الإجازة', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: _reasonController, decoration: InputDecoration(labelText: 'سبب الإجازة / تفاصيل', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))), maxLines: 2),
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22A39F), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: _submitLeave, child: const Text('إرسال الطلب', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
                ],
              ),
            ),
          ),
          const Divider(),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child: Align(alignment: Alignment.centerRight, child: Text('طلباتي السابقة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A5F7A))))),
          Expanded(
            child: _myLeaves.isEmpty
                ? const Center(child: Text('لا توجد طلبات إجازة سابقة', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _myLeaves.length,
                    itemBuilder: (context, index) {
                      final leave = _myLeaves[_myLeaves.length - 1 - index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          leading: const CircleAvatar(backgroundColor: Color(0xFF1A5F7A), child: Icon(Icons.flight_takeoff, color: Colors.white, size: 20)),
                          title: Text(leave['type'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('السبب: ${leave['reason']}\nالتاريخ: ${leave['date']}'),
                          isThreeLine: true,
                          trailing: Chip(label: Text(leave['status'], style: const TextStyle(fontSize: 11, color: Colors.white)), backgroundColor: Colors.orange),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}