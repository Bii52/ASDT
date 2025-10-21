import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'reminders_provider.dart';
import 'reminder.dart';

class AddReminderPage extends ConsumerStatefulWidget {
  const AddReminderPage({super.key});
  @override
  ConsumerState<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends ConsumerState<AddReminderPage> {
  final name = TextEditingController();
  TimeOfDay tod = const TimeOfDay(hour: 8, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm nhắc uống thuốc')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Tên thuốc')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Text('Giờ: ${tod.format(context)}')),
            TextButton(
              onPressed: () async {
                final picked = await showTimePicker(context: context, initialTime: tod);
                if (picked != null) setState(() => tod = picked);
              },
              child: const Text('Chọn giờ'),
            ),
          ]),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              final now = DateTime.now();
              final time = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
              ref.read(remindersProvider.notifier).add(
                Reminder(id: const Uuid().v4(), medicine: name.text.trim(), time: time),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Lưu'),
          ),
        ]),
      ),
    );
  }
}
