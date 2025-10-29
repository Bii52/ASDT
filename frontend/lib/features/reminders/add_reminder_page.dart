import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'reminders_provider.dart';
import 'reminder.dart';

class AddReminderPage extends ConsumerStatefulWidget {
  final String? initialMedicine;
  const AddReminderPage({super.key, this.initialMedicine});
  @override
  ConsumerState<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends ConsumerState<AddReminderPage> {
  final name = TextEditingController();
  int pills = 1;
  List<TimeOfDay> times = [const TimeOfDay(hour: 8, minute: 0)];

  @override
  void initState() {
    super.initState();
    if (widget.initialMedicine != null && widget.initialMedicine!.isNotEmpty) {
      name.text = widget.initialMedicine!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm nhắc uống thuốc')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Tên thuốc từ toa của bạn'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Số viên mỗi lần:'),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => setState(() { if (pills > 1) pills--; }),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('$pills'),
              IconButton(
                onPressed: () => setState(() { pills++; }),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Giờ uống (có thể chọn nhiều):', style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < times.length; i++)
                Chip(
                  label: Text(times[i].format(context)),
                  onDeleted: times.length > 1 ? () => setState(() => times.removeAt(i)) : null,
                ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('Thêm giờ'),
                onPressed: () async {
                  final picked = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 8, minute: 0));
                  if (picked != null) setState(() => times.add(picked));
                },
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final med = name.text.trim();
                if (med.isEmpty || times.isEmpty) return;
                final timeStrings = times.map((t) =>
                  '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}'
                ).toList();
                ref.read(remindersProvider.notifier).add(
                  Reminder(
                    id: const Uuid().v4(),
                    medicine: med,
                    pills: pills,
                    times: timeStrings,
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Lưu'),
            ),
          ),
        ]),
      ),
    );
  }
}
