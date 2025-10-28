import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../services/auth_service.dart';
import '../providers/chat_provider.dart';


class OnlineDoctorsPage extends ConsumerStatefulWidget {
  const OnlineDoctorsPage({super.key});

  @override
  ConsumerState<OnlineDoctorsPage> createState() => _OnlineDoctorsPageState();
}

class _OnlineDoctorsPageState extends ConsumerState<OnlineDoctorsPage> {
  List<Map<String, dynamic>> _doctors = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      const baseUrl = kIsWeb ? 'http://localhost:5000/api' : 'http://192.168.100.191:5000/api';
      final response = await http.get(
        Uri.parse('$baseUrl/auth/doctors'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ref.read(authProvider).token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _doctors = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Không thể tải danh sách bác sĩ';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi tải danh sách bác sĩ: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Bác sĩ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDoctors,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDoctors,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _doctors.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Không có bác sĩ nào',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Vui lòng thử lại sau',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _doctors.length,
                      itemBuilder: (context, index) {
                        final doctor = _doctors[index];
                        return DoctorCard(
                          doctor: doctor,
                          onTap: () {
                            // Navigate to start chat with specific doctor
                            context.push('/chat/start');
                          },
                        );
                      },
                    ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onTap;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fullName = doctor['fullName'] ?? 'Bác sĩ';
    final specialization = doctor['specialization'] ?? '';
    final avatar = doctor['avatar'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: avatar != null ? NetworkImage(avatar) : null,
          child: avatar == null 
              ? Text(
                  fullName.isNotEmpty ? fullName[0].toUpperCase() : 'B',
                  style: const TextStyle(fontSize: 18),
                )
              : null,
        ),
        title: Text(
          fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (specialization.isNotEmpty) ...[
              Text(
                specialization,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
            ],
          ],
        ),
        trailing: const Icon(Icons.chat_bubble_outline),
        onTap: onTap,
      ),
    );
  }
}
