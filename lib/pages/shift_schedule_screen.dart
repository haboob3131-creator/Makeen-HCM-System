import 'package:flutter/material.dart';

class ShiftScheduleScreen extends StatelessWidget {
  const ShiftScheduleScreen({super.key});

  // بناء شاشة جدول الورديات وعرض قائمة الورديات القادمة واليوم الحالي
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> shifts = [
      {"day": "السبت", "date": "5 سبتمبر", "shift": "الوردية الصباحية", "time": "08:00 ص - 04:00 م", "status": "اليوم"},
      {"day": "الأحد", "date": "6 سبتمبر", "shift": "الوردية الصباحية", "time": "08:00 ص - 04:00 م", "status": "قادم"},
      {"day": "الإثنين", "date": "7 سبتمبر", "shift": "الوردية المسائية", "time": "04:00 م - 12:00 ص", "status": "قادم"},
      {"day": "الثلاثاء", "date": "8 سبتمبر", "shift": "الوردية المسائية", "time": "04:00 م - 12:00 ص", "status": "قادم"},
      {"day": "الأربعاء", "date": "9 سبتمبر", "shift": "الوردية الصباحية", "time": "08:00 ص - 04:00 م", "status": "قادم"},
      {"day": "الخميس", "date": "10 سبتمبر", "shift": "إجازة أسبوعية", "time": "راحة", "status": "إجازة"},
      {"day": "الجمعة", "date": "11 سبتمبر", "shift": "إجازة أسبوعية", "time": "راحة", "status": "إجازة"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('جدول الورديات', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1A5F7A), iconTheme: const IconThemeData(color: Colors.white)), 
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: shifts.length,
        itemBuilder: (context, index) {
          final shift = shifts[index];
          final isOff = shift['status'] == 'إجازة';
          final isToday = shift['status'] == 'اليوم';

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: isOff ? Colors.grey.shade200 : const Color(0xFF22A39F).withValues(alpha: 0.2),
                child: Icon(isOff ? Icons.weekend : Icons.work, color: isOff ? Colors.grey : const Color(0xFF1A5F7A)),
              ),
              title: Text('${shift["day"]} - ${shift["date"]}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Padding(padding: const EdgeInsets.only(top: 8.0), child: Text('${shift["shift"]}\n${shift["time"]}')),
              trailing: Chip(
                label: Text(shift["status"]!, style: TextStyle(color: isOff ? Colors.black54 : Colors.white, fontSize: 12)),
                backgroundColor: isToday ? Colors.green : (isOff ? Colors.grey.shade300 : const Color(0xFF1A5F7A)),
              ),
            ),
          );
        },
      ),
    );
  }
}