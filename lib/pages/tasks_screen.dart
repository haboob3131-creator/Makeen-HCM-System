import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  // قائمة الزيارات الميدانية المحفوظة داخل التطبيق
  List<Map<String, dynamic>> _visits = [];

  // يحدد ما إذا كان التطبيق الآن جالبًا للموقع أو في حالة انتظار
  bool _isLocating = false;

  // تهيئة الشاشة وتحميل الزيارات المحفوظة عند فتحها
  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  // جلب الزيارات المحفوظة من ذاكرة الهاتف
  Future<void> _loadVisits() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedVisits = prefs.getStringList('field_visits') ?? [];
    setState(() {
      _visits = savedVisits.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    });
  }

  // هذه الدالة تبدأ زيارة جديدة عن طريق جلب الموقع الحالي من GPS
  Future<void> _startNewVisit() async {
    setState(() => _isLocating = true); // إظهار مؤشر التحميل

    // فحص صلاحيات الموقع
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() => _isLocating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تفعيل خدمة الموقع في الهاتف'), backgroundColor: Colors.orange),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      if (!mounted) return;
      setState(() => _isLocating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفض صلاحية الموقع. قم بتفعيلها من إعدادات الهاتف'), backgroundColor: Colors.orange),
      );
      return;
    }

    double lat = 15.3483; // إحداثيات افتراضية (صنعاء) في حال فشل الـ GPS
    double lng = 44.2065;

    try {
      // محاولة جلب الموقع الحقيقي بحد أقصى 5 ثوانٍ لكي لا يطول الانتظار في العرض
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      lat = position.latitude;
      lng = position.longitude;
    } catch (e) {
      debugPrint('فشل في جلب الموقع، سيتم استخدام الإحداثيات الافتراضية');
    }

    setState(() => _isLocating = false); // إخفاء مؤشر التحميل

    // فتح النافذة المنبثقة (Bottom Sheet) لإدخال البيانات
    if (mounted) {
      _showVisitFormDialog(lat, lng);
    }
  }

  // نافذة منبثقة لإدخال اسم المحل والملاحظات على الزيارة
  void _showVisitFormDialog(double lat, double lng) {
    final TextEditingController storeNameController = TextEditingController();
    final TextEditingController notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // لتجنب مشكلة الكيبورد الذي يغطي الحقول
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // رفع النافذة فوق الكيبورد
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('تسجيل زيارة ميدانية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A5F7A))),
              const SizedBox(height: 10),
              
              // عرض الإحداثيات التي تم التقاطها
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 20),
                  Text(' الإحداثيات: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}', style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 20),

              TextField(
                controller: storeNameController,
                decoration: InputDecoration(
                  labelText: 'اسم المحل / العميل',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.store, color: Color(0xFF22A39F)),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'الملاحظات / نتائج الزيارة',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5F7A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    if (storeNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى كتابة اسم المحل'), backgroundColor: Colors.red));
                      return;
                    }
                    // حفظ البيانات
                    await _saveVisitData(storeNameController.text, notesController.text, lat, lng);
                    if (context.mounted) Navigator.pop(context); // إغلاق النافذة
                  },
                  child: const Text('حفظ الزيارة', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }

  // حفظ بيانات الزيارة في التخزين المحلي داخل الهاتف
  Future<void> _saveVisitData(String storeName, String notes, double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedVisits = prefs.getStringList('field_visits') ?? [];
    
    final now = DateTime.now();
    final timeString = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
    final dateString = "${now.day}/${now.month}/${now.year}";

    final newVisit = {
      "storeName": storeName,
      "notes": notes.isEmpty ? "لا توجد ملاحظات" : notes,
      "time": "$timeString - $dateString",
      "location": "${lat.toStringAsFixed(4)} , ${lng.toStringAsFixed(4)}"
    };

    savedVisits.add(jsonEncode(newVisit));
    await prefs.setStringList('field_visits', savedVisits);
    
    _loadVisits(); // تحديث القائمة فوراً
  }

  // بناء شاشة الزيارات الميدانية مع زر إضافة جديدة وقائمة المحفوظات
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الزيارات الميدانية', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A5F7A),
        automaticallyImplyLeading: false, // لأنها موجودة في الشريط السفلي
      ),
      // زر الإضافة العائم
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF22A39F),
        onPressed: _isLocating ? null : _startNewVisit,
        icon: _isLocating 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.add_location_alt, color: Colors.white),
        label: Text(_isLocating ? 'جاري تحديد الموقع...' : 'توثيق زيارة جديدة', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _visits.isEmpty
          ? const Center(child: Text('لم تقم بأي زيارات ميدانية بعد', style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // مساحة سفلية لكي لا يغطي الزر العائم آخر عنصر
              itemCount: _visits.length,
              itemBuilder: (context, index) {
                // عكس القائمة لعرض الأحدث أولاً
                final visit = _visits[_visits.length - 1 - index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(backgroundColor: Color(0xFF1A5F7A), child: Icon(Icons.store, color: Colors.white)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(visit['storeName'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A5F7A))),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(visit['time'], style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.red),
                            const SizedBox(width: 6),
                            Text('الإحداثيات: ${visit['location']}', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                          child: Text('ملاحظات: ${visit['notes']}', style: const TextStyle(fontSize: 14)),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}