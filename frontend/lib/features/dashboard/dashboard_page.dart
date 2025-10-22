import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _DashCard(
        title: 'Hồ sơ y tế',
        subtitle: 'BMI, chiều cao, cân nặng',
        icon: Icons.person_outline,
        onTap: () => context.push('/profile'),
      ),
      _DashCard(
        title: 'Bài viết sức khỏe',
        subtitle: 'Tin & kiến thức y khoa',
        icon: Icons.article_outlined,
        onTap: () => context.push('/articles'),
      ),
      _DashCard(
        title: 'Nhắc uống thuốc',
        subtitle: 'Thiết lập lịch uống',
        icon: Icons.alarm,
        onTap: () => context.push('/reminders'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Chăm Sóc Sức Khỏe')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: cards,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reminders/add'),
        label: const Text('Thêm nhắc'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _DashCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _DashCard({required this.title, required this.subtitle, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, size: 28),
            const Spacer(),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      ),
    );
  }
}
