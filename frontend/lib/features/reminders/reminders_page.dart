import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'reminders_provider.dart';

class RemindersPage extends ConsumerWidget {
  const RemindersPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(remindersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Nhắc uống thuốc')),
      body: list.isEmpty
          ? const Center(child: Text('Chưa có nhắc nào'))
          : ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (_, i) {
                final r = list[i];
                return ListTile(
                  leading: const Icon(Icons.alarm),
                  title: Text(r.medicine),
                  subtitle: Text('Số viên: ${r.pills} • Giờ: ${r.times.join(', ')}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => ref.read(remindersProvider.notifier).remove(r.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/reminders/add'), // This now correctly points to the new single-add page
        child: const Icon(Icons.add),
      ),
    );
  }
}
