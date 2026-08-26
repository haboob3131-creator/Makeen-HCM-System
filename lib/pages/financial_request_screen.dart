import 'package:flutter/material.dart';

class FinancialRequestScreen extends StatelessWidget {
  const FinancialRequestScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الطلبات المالية (سلف/عهد)'), backgroundColor: const Color(0xFF1A5F7A)), 
      body: const Center(child: Text('نموذج تقديم السلف والعهد المالية'))
    );
  }
}