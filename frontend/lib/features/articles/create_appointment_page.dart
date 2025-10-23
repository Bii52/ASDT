import 'dart:convert';
import 'dart:io'; // Để kiểm tra SocketException
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// TODO: Di chuyển các hằng số này vào một tệp cấu hình riêng
const String apiBaseUrl = 'http://10.0.2.2:5000';

class CreateAppointmentPage extends StatefulWidget {
  final String doctorId;
  const CreateAppointmentPage({super.key, required this.doctorId});

  @override
  State<CreateAppointmentPage> createState() => _CreateAppointmentPageState();
}

class _CreateAppointmentPageState extends State<CreateAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isLoading = false;
  String? _error;

  // TODO: Thay thế bằng token của người dùng đã đăng nhập
  // Token nên được lấy từ một nơi quản lý trạng thái hoặc bộ nhớ an toàn
  final String _authToken = "YOUR_AUTH_TOKEN_HERE"; 

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _submitAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      setState(() {
        _error = 'Vui lòng chọn ngày và giờ hẹn.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final timeString = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/appointments'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_authToken', // Gửi token để xác thực
        },
        body: jsonEncode({
          'doctorId': widget.doctorId,
          'date': dateString,
          'startTime': timeString,
          'reason': _reasonController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt lịch hẹn thành công!')),
        );
        if (context.mounted) context.pop();
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Đặt lịch hẹn thất bại. Vui lòng thử lại.';
      }
    } on SocketException {
      _error = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
    } catch (e) {
      // Ghi lại lỗi để debug
      debugPrint('Lỗi khi đặt lịch hẹn: $e');
      _error = 'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt lịch hẹn')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // TODO: Thay vì hiển thị ID, bạn nên truy vấn thông tin bác sĩ (tên, chuyên khoa) để hiển thị
            Text('Đặt lịch hẹn với Bác sĩ', style: Theme.of(context).textTheme.titleLarge),
            // Text(widget.doctorId, style: Theme.of(context).textTheme.bodySmall), // Có thể hiển thị ID một cách kín đáo hơn nếu cần
            const SizedBox(height: 16),
            // --- Chọn ngày ---
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Ngày hẹn'),
              subtitle: Text(
                _selectedDate == null
                    ? 'Chưa chọn'
                    : DateFormat('dd/MM/yyyy').format(_selectedDate!),
              ),
              onTap: _pickDate,
            ),
            // --- Chọn giờ ---
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Giờ hẹn'),
              subtitle: Text(
                _selectedTime == null ? 'Chưa chọn' : _selectedTime!.format(context),
              ),
              onTap: _pickTime,
            ),
            const SizedBox(height: 16),
            // --- Lý do khám ---
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Lý do khám',
                hintText: 'Mô tả ngắn gọn triệu chứng của bạn...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập lý do khám.';
                }
                if (value.length < 10) {
                  return 'Lý do khám phải có ít nhất 10 ký tự.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            // --- Nút Gửi ---
            ElevatedButton(
              onPressed: _isLoading ? null : _submitAppointment,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Xác nhận đặt lịch'),
            ),
          ],
        ),
      ),
    );
  }
}