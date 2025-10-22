import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});
  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final name = TextEditingController();
  final height = TextEditingController();
  final weight = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(profileProvider);
    name.text = name.text.isEmpty ? p.name : name.text;
    height.text = height.text.isEmpty ? p.height.toString() : height.text;
    weight.text = weight.text.isEmpty ? p.weight.toString() : weight.text;

    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Họ tên')),
          TextField(controller: height, decoration: const InputDecoration(labelText: 'Chiều cao (m)'), keyboardType: TextInputType.number),
          TextField(controller: weight, decoration: const InputDecoration(labelText: 'Cân nặng (kg)'), keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              ref.read(profileProvider.notifier).update(
                name: name.text.trim(),
                height: double.tryParse(height.text),
                weight: double.tryParse(weight.text),
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
