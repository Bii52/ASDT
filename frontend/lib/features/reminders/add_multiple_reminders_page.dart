import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'reminder.dart';
import 'reminders_provider.dart';

class AddMultipleRemindersPage extends ConsumerStatefulWidget {
  final List<String>? initialMedicineNames;
  const AddMultipleRemindersPage({super.key, this.initialMedicineNames});

  @override
  ConsumerState<AddMultipleRemindersPage> createState() => _AddMultipleRemindersPageState();
}

class _AddMultipleRemindersPageState extends ConsumerState<AddMultipleRemindersPage> {
  final List<_MedicineForm> _forms = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialMedicineNames != null && widget.initialMedicineNames!.isNotEmpty) {
      for (final name in widget.initialMedicineNames!) {
        _forms.add(_MedicineForm(initialName: name));
      }
    } else {
      // Nếu không có thuốc nào được truyền vào, tạo một form trống
      _forms.add(_MedicineForm());
    }
  }
  
  void _addMedicine() {
    setState(() => _forms.add(_MedicineForm()));
  }

  void _removeMedicine(int index) {
    setState(() => _forms.removeAt(index));
  }

  void _saveAll() {
    final uuid = const Uuid();
    final reminders = _forms.map((f) {
      final name = f.nameController.text.trim();
      if (name.isEmpty) return null;
      final times = f.times.map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}').toList();
      return Reminder(
        id: uuid.v4(),
        medicine: name,
        pills: f.pills,
        times: times,
      );
    }).whereType<Reminder>().toList();

    if (reminders.isEmpty) return;

    ref.read(remindersProvider.notifier).addAll(reminders);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm nhiều thuốc'),
        actions: [IconButton(onPressed: _saveAll, icon: const Icon(Icons.save))],
      ),
      body: ListView.builder(
        itemCount: _forms.length,
        itemBuilder: (_, i) {
          final f = _forms[i];
          return Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: f.nameController,
                    decoration: const InputDecoration(labelText: 'Tên thuốc'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Số viên:'),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => setState(() { if (f.pills > 1) f.pills--; }),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('${f.pills}'),
                      IconButton(
                        onPressed: () => setState(() { f.pills++; }),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Giờ uống:', style: Theme.of(context).textTheme.bodyMedium),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int j = 0; j < f.times.length; j++)
                        Chip(
                          label: Text(f.times[j].format(context)),
                          onDeleted: f.times.length > 1
                              ? () => setState(() => f.times.removeAt(j))
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
                          if (picked != null) setState(() => f.times.add(picked));
                        },
                      ),
                    ],
                  ),
                  if (_forms.length > 1)
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () => _removeMedicine(i),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_medicine',
        onPressed: _addMedicine,
        label: const Text('Thêm thuốc khác'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _MedicineForm {
  final TextEditingController nameController;
  int pills = 1;
  List<TimeOfDay> times = [const TimeOfDay(hour: 8, minute: 0)];

  _MedicineForm({String? initialName})
      : nameController = TextEditingController(text: initialName);
}
