import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';

class PharmacistProfileView extends ConsumerWidget {
  const PharmacistProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ Dược sĩ'),
      ),
      body: Center(child: Text('Hồ sơ của Dược sĩ: ${user.fullName}')),
    );
  }
}
