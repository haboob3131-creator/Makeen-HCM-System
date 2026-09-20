import 'package:flutter/material.dart';
import 'home_dashboard_screen.dart';
import 'tasks_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // الفهرس الحالي للصفحة النشطة في شريط التنقل السفلي
  int _currentIndex = 0;

  // قائمة الشاشات المتاحة في شريط التنقل السفلي
  final List<Widget> _screens = [
    const HomeDashboardScreen(),
    const TasksScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  // بناء شريط التنقل السفلي الرئيسي
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1A5F7A),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'المهام'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'الإشعارات'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}