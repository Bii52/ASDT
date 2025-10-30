import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/auth_service.dart';

class DoctorProfileView extends ConsumerWidget {
  const DoctorProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ Bác sĩ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/profile/edit'),
            tooltip: 'Chỉnh sửa',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Cài đặt',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
                  child: user.avatar == null ? const Icon(Icons.medical_services_outlined, size: 50) : null,
                ),
                const SizedBox(height: 16),
                Text('BS. ${user.fullName}', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(user.specialty ?? 'Chưa cập nhật chuyên khoa', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).primaryColor)),
                const SizedBox(height: 8),
                Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Thông tin chuyên môn'),
            subtitle: Text(user.bio ?? 'Chưa có thông tin.'),
          ),
          const Divider(),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => ref.read(authProvider.notifier).logout().then((_) => context.go('/login')),
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
