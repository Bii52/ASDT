import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class DoctorProfilePage extends ConsumerStatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  ConsumerState<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends ConsumerState<DoctorProfilePage> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() { _loading = true; _error = null; });
      final res = await ApiService.get('auth/profile');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() {
          _profile = body['user'] ?? body;
          _loading = false;
        });
      } else {
        setState(() { _error = 'Không lấy được hồ sơ'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Lỗi: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ bác sĩ')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(_error!),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _loadProfile, child: const Text('Thử lại')),
                    ],
                  ),
                )
              : _profile == null
                  ? const Center(child: Text('Không có dữ liệu'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundImage: _profile!['avatar'] != null ? NetworkImage(_profile!['avatar']) : null,
                                child: _profile!['avatar'] == null
                                    ? Text(
                                        (_profile!['fullName'] ?? 'B')[0].toUpperCase(),
                                        style: const TextStyle(fontSize: 24),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_profile!['fullName'] ?? 'Bác sĩ', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    Text(_profile!['specialty'] ?? _profile!['specialization'] ?? 'Bác sĩ'),
                                    if (_profile!['licenseNumber'] != null) Text('Giấy phép: ${_profile!['licenseNumber']}'),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_profile!['bio'] != null) ...[
                            const Text('Giới thiệu', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(_profile!['bio']),
                            const SizedBox(height: 12),
                          ],
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text('${_profile!['averageRating'] ?? 0} (${_profile!['totalRatings'] ?? 0} đánh giá)'),
                            ],
                          ),
                        ],
                      ),
                    ),
    );
  }
}


