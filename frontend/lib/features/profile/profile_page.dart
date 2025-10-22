import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ y tế')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Họ tên: ${p.name}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Chiều cao: ${p.height.toStringAsFixed(2)} m'),
          Text('Cân nặng: ${p.weight.toStringAsFixed(1)} kg'),
          const SizedBox(height: 8),
          Text('BMI: ${p.bmi.toStringAsFixed(1)}'),
          const Spacer(),
          FilledButton(onPressed: () => context.push('/profile/edit'), child: const Text('Chỉnh sửa')),
        ]),
      ),
    );
  }
}
