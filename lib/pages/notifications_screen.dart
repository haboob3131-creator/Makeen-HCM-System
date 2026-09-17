import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> notifications = [
    {"id": "1", "title": "تمت الموافقة على السلفة", "body": "قام المدير المالي باعتماد طلب السلفة الخاص بك.", "time": "منذ ساعتين", "icon": Icons.check_circle, "color": Colors.green},
    {"id": "2", "title": "إشعار راتب جديد", "body": "تم إصدار مسير الرواتب لشهر أغسطس. يمكنك الاطلاع عليه الآن.", "time": "أمس", "icon": Icons.account_balance_wallet, "color": const Color(0xFF1A5F7A)},
    {"id": "3", "title": "تذكير بجدول الورديات", "body": "وردتك غداً تبدأ الساعة 8:00 صباحاً. يرجى الالتزام بالموعد.", "time": "منذ 3 أيام", "icon": Icons.access_time, "color": Colors.orange},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1A5F7A), automaticallyImplyLeading: false), 
      body: notifications.isEmpty
          ? const Center(child: Text('لا توجد إشعارات جديدة حالياً', style: TextStyle(fontSize: 16, color: Colors.grey)))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Dismissible(
                  key: Key(notif['id']),
                  direction: DismissDirection.endToStart,
                  background: Container(color: Colors.red, alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 20), child: const Icon(Icons.delete, color: Colors.white)),
                  onDismissed: (direction) {
                    setState(() => notifications.removeAt(index));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف الإشعار'), duration: Duration(seconds: 1)));
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: notif['color'].withOpacity(0.2), child: Icon(notif['icon'], color: notif['color'])),
                      title: Text(notif['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(notif['body'], style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 8),
                          Text(notif['time'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  ),
                );
              },
            ),
    );
  }
}