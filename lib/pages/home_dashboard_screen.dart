import 'package:flutter/material.dart';
import 'check_in_screen.dart';
import 'attendance_log_screen.dart';
import 'leave_request_screen.dart';
import 'financial_request_screen.dart';
import 'shift_schedule_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مرحباً بك في مكين'), backgroundColor: const Color(0xFF1A5F7A)),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildActionCard(context, 'التوثيق الميداني', Icons.location_on, const CheckInScreen()),
          _buildActionCard(context, 'السجل الزمني', Icons.access_time, const AttendanceLogScreen()),
          _buildActionCard(context, 'طلبات الإجازات', Icons.flight_takeoff, const LeaveRequestScreen()),
          _buildActionCard(context, 'الطلبات المالية', Icons.attach_money, const FinancialRequestScreen()),
          _buildActionCard(context, 'جدول الورديات', Icons.calendar_month, const ShiftScheduleScreen()),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Widget targetScreen) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen)),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: const Color(0xFF22A39F)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A5F7A))),
          ],
        ),
      ),
    );
  }
}