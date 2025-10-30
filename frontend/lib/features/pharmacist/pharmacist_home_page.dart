import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PharmacistHomePage extends StatelessWidget {
  const PharmacistHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dược sĩ')), 
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NavTile(
            icon: Icons.inventory_2_outlined,
            title: 'Quản lý sản phẩm',
            onTap: () => context.push('/pharmacist/products'),
          ),
          _NavTile(
            icon: Icons.category_outlined,
            title: 'Quản lý danh mục',
            onTap: () => context.push('/pharmacist/categories'),
          ),
          _NavTile(
            icon: Icons.qr_code_scanner,
            title: 'Quét mã QR',
            onTap: () => context.push('/pharmacist/qr'),
          ),
          _NavTile(
            icon: Icons.insights_outlined,
            title: 'Thống kê',
            onTap: () => context.push('/pharmacist/stats'),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _NavTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}


