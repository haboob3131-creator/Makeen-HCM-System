import 'package:flutter/material.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التوثيق الميداني'), backgroundColor: const Color(0xFF1A5F7A)),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: const Center(child: Text('الخريطة (OpenStreetMap) سيتم إضافتها هنا')),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('الموقع الحالي: جاري جلب الإحداثيات...', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const TextField(decoration: InputDecoration(labelText: 'ملاحظات الزيارة', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: const Color(0xFF1A5F7A)),
                  onPressed: () {},
                  icon: const Icon(Icons.fingerprint, color: Colors.white),
                  label: const Text('تأكيد الوصول (Check-In)', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}