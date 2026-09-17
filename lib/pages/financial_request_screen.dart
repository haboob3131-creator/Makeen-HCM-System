import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FinancialRequestScreen extends StatefulWidget {
  const FinancialRequestScreen({super.key});

  @override
  State<FinancialRequestScreen> createState() => _FinancialRequestScreenState();
}

class _FinancialRequestScreenState extends State<FinancialRequestScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  String _selectedType = 'سلفة';
  List<Map<String, dynamic>> _myFinancials = [];

  @override
  void initState() {
    super.initState();
    _loadFinancials(); 
  }

  Future<void> _loadFinancials() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedData = prefs.getStringList('financial_requests') ?? [];
    setState(() {
      _myFinancials = savedData.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    });
  }

  Future<void> _submitRequest() async {
    if (_amountController.text.isEmpty || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إدخال المبلغ والغرض'), backgroundColor: Colors.red));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    List<String> logs = prefs.getStringList('financial_requests') ?? [];
    
    final newReq = {
      "type": _selectedType,
      "amount": _amountController.text,
      "reason": _reasonController.text,
      "date": "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
      "status": "قيد المراجعة"
    };
    
    logs.add(jsonEncode(newReq));
    await prefs.setStringList('financial_requests', logs);
    
    _amountController.clear();
    _reasonController.clear();
    FocusScope.of(context).unfocus();
    _loadFinancials();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفع الطلب المالي بنجاح'), backgroundColor: Colors.green));
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الطلبات المالية', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1A5F7A), iconTheme: const IconThemeData(color: Colors.white)), 
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
                  const Text('تقديم طلب مالي جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A5F7A))),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    items: ['سلفة', 'عهدة مالية'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                    onChanged: (val) => setState(() => _selectedType = val!),
                    decoration: InputDecoration(labelText: 'نوع الطلب', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'المبلغ (ريال يمني)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), prefixIcon: const Icon(Icons.money))),
                  const SizedBox(height: 12),
                  TextField(controller: _reasonController, decoration: InputDecoration(labelText: 'الغرض من الطلب', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22A39F), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: _submitRequest, child: const Text('إرسال الطلب', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
                ],
              ),
            ),
          ),
          const Divider(),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child: Align(alignment: Alignment.centerRight, child: Text('طلباتي السابقة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A5F7A))))),
          Expanded(
            child: _myFinancials.isEmpty
                ? const Center(child: Text('لا توجد طلبات مالية سابقة', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _myFinancials.length,
                    itemBuilder: (context, index) {
                      final req = _myFinancials[_myFinancials.length - 1 - index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.attach_money, color: Colors.white)),
                          title: Text('${req['type']} - ${req['amount']} ريال', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('الغرض: ${req['reason']}\nالتاريخ: ${req['date']}'),
                          isThreeLine: true,
                          trailing: Chip(label: Text(req['status'], style: const TextStyle(fontSize: 11, color: Colors.white)), backgroundColor: Colors.orange),
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