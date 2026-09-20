import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:async';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  // الوقت الحالي الذي سيتم عرضه في الشاشة
  String _currentTime = '';

  // Timer لتحديث الساعة كل ثانية
  Timer? _timer;

  // إحداثيات افتراضية (صنعاء) في حال فشل الـ GPS داخل قاعة العرض
  LatLng _currentLocation = const LatLng(15.3483, 44.2065);

  // حالة تحميل الموقع الحالية
  bool _isLoadingLocation = true;

  // وحدة التحكم بالخريطة لتحديث موقع المستخدم على الخريطة
  final MapController _mapController = MapController();

  // تهيئة الشاشة عند فتحها
  @override
  void initState() {
    super.initState();
    // تشغيل الساعة
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          final now = DateTime.now();
          _currentTime = "${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
        });
      }
    });

    // محاولة جلب الموقع الفعلي فور فتح الشاشة
    _determinePosition();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // هذه الدالة تقوم بجلب الموقع الفعلي عبر GPS وتحديث الخريطة
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoadingLocation = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoadingLocation = false);
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoadingLocation = false);
      return;
    }

    // جلب الإحداثيات الفعلية بنجاح
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _isLoadingLocation = false;
    });
    
    // تحريك الخريطة للموقع الفعلي
    _mapController.move(_currentLocation, 15.0);
  }

  // هذه الدالة تحفظ سجل الحضور أو الانصراف داخل الهاتف مع الموقع والوقت
  Future<void> _saveAttendance(String type) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> logs = prefs.getStringList('attendance_logs') ?? [];
    
    final now = DateTime.now();
    final timeString = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
    final dateString = "${now.day}/${now.month}/${now.year}";
    
    // حفظ نوع التوثيق مع الإحداثيات التي تم التقاطها
    final newRecord = {
      "type": type,
      "time": "$timeString - $dateString",
      "location": "الإحداثيات: ${_currentLocation.latitude.toStringAsFixed(4)}, ${_currentLocation.longitude.toStringAsFixed(4)}", 
    };
    
    logs.add(jsonEncode(newRecord));
    await prefs.setStringList('attendance_logs', logs);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تسجيل $type بنجاح!'), 
          backgroundColor: type == 'حضور' ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        )
      );
    }
  }

  // بناء واجهة التوثيق الميداني
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التوثيق الميداني', style: TextStyle(color: Colors.white)), 
        backgroundColor: const Color(0xFF1A5F7A),
        iconTheme: const IconThemeData(color: Colors.white),
      ), 
      body: Column(
        children: [
          // القسم العلوي: الخريطة التفاعلية
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation,
                    initialZoom: 14.0,
                  ),
                  children: [
                    // طبقة الخريطة المفتوحة (OpenStreetMap) المجانية
                    TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'], // يجب إضافة هذا السطر مع Carto
                    userAgentPackageName: 'com.example.app',
                    ),
                    // مؤشر موقع الموظف
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLocation,
                          width: 80,
                          height: 80,
                          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_isLoadingLocation)
                  Container(
                    color: Colors.white.withValues(alpha: 0.7),
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFF1A5F7A)),
                    ),
                  ),
              ],
            ),
          ),
          
          // القسم السفلي: الساعة وأزرار التوثيق
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentTime, 
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1A5F7A))
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _isLoadingLocation ? 'جاري تحديد الموقع...' : 'تم التقاط الموقع بنجاح', 
                    style: TextStyle(fontSize: 14, color: _isLoadingLocation ? Colors.grey : Colors.green)
                  ),
                  
                  const Spacer(),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          onPressed: _isLoadingLocation ? null : () => _saveAttendance("حضور"),
                          icon: const Icon(Icons.login, color: Colors.white),
                          label: const Text('تسجيل حضور', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          onPressed: _isLoadingLocation ? null : () => _saveAttendance("انصراف"),
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text('تسجيل انصراف', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}