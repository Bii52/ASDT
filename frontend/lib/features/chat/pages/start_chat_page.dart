import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/chat_provider.dart';
import '../../../services/chat_service.dart';
import '../../../services/auth_service.dart';
import '../models/conversation.dart';
import 'chat_detail_page.dart';

class StartChatPage extends ConsumerStatefulWidget {
  const StartChatPage({super.key});

  @override
  ConsumerState<StartChatPage> createState() => _StartChatPageState();
}

class _StartChatPageState extends ConsumerState<StartChatPage> {
  List<Map<String, dynamic>> _doctors = [];
  bool _isLoading = true;
  String? _error;
  bool _startingChat = false;

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

  Future<void> _startChatWithDoctor(String doctorId, String doctorName) async {
    try {
      if (_startingChat) return;
      setState(() { _startingChat = true; });
      // Tạo hoặc lấy conversation, KHÔNG gửi tin nhắn mẫu
      final conversation = await ChatService.createOrGetConversation(doctorId);

      // Cập nhật danh sách conversations và điều hướng thẳng vào màn chi tiết chat
      ref.read(conversationsProvider.notifier).addConversation(conversation);

      if (mounted) {
        // Điều hướng sau frame để tránh lỗi Navigator !_debugLocked trên Web
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailPage(conversation: conversation),
            ),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi bắt đầu cuộc trò chuyện: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() { _startingChat = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn bác sĩ để chat'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                          onTap: () => _startChatWithDoctor(
                            doctor['_id'],
                            doctor['fullName'],
                          ),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: doctor['avatar'] != null
              ? NetworkImage(doctor['avatar'])
              : null,
          child: doctor['avatar'] == null
              ? Text(
                  doctor['fullName']?.isNotEmpty == true
                      ? doctor['fullName'][0].toUpperCase()
                      : 'B',
                  style: const TextStyle(fontSize: 18),
                )
              : null,
        ),
        title: Text(
          doctor['fullName'] ?? 'Bác sĩ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(doctor['specialization'] ?? 'Bác sĩ tổng quát'),
        trailing: const Icon(Icons.chat_bubble_outline),
        onTap: onTap,
      ),
    );
  }
}
