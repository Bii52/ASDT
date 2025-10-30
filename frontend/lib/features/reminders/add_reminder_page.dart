import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'reminder.dart';
import 'reminders_provider.dart';

class AddReminderPage extends ConsumerStatefulWidget {
  final String? initialMedicineName;
  const AddReminderPage({super.key, this.initialMedicineName});

  @override
  ConsumerState<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends ConsumerState<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _pills = 1;
  final List<TimeOfDay> _times = [const TimeOfDay(hour: 8, minute: 0)];

  @override
  void initState() {
    super.initState();
    if (widget.initialMedicineName != null) {
      _nameController.text = widget.initialMedicineName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final times = _times
        .map((t) =>
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
        .toList();

    final reminder = Reminder(
      id: const Uuid().v4(),
      medicine: name,
      pills: _pills,
      times: times,
    );

    ref.read(remindersProvider.notifier).add(reminder);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm nhắc uống thuốc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
            tooltip: 'Lưu',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên thuốc',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Vui lòng nhập tên thuốc' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.medication),
              title: const Text('Số viên mỗi lần'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => setState(() {
                      if (_pills > 1) _pills--;
                    }),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_pills', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    onPressed: () => setState(() => _pills++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text('Giờ uống', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (int i = 0; i < _times.length; i++)
                  Chip(
                    label: Text(_times[i].format(context)),
                    onDeleted: _times.length > 1
                        ? () => setState(() => _times.removeAt(i))
                        : null,
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm giờ'),
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 8, minute: 0),
                    );
                    if (picked != null && !_times.contains(picked)) {
                      setState(() => _times.add(picked));
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () => context.push('/reminders/add-multiple'),
                child: const Text('Thêm nhiều loại thuốc cùng lúc?'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}