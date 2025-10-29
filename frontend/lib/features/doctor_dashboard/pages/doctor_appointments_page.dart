import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/appointment_service.dart';

class DoctorAppointmentsPage extends ConsumerStatefulWidget {
  const DoctorAppointmentsPage({super.key});

  @override
  ConsumerState<DoctorAppointmentsPage> createState() => _DoctorAppointmentsPageState();
}

class _DoctorAppointmentsPageState extends ConsumerState<DoctorAppointmentsPage> {
  late Future<List<dynamic>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _fetchAppointments();
  }

  Future<List<dynamic>> _fetchAppointments() async {
    final response = await AppointmentService.getDoctorAppointments();
    if (response['success'] == true) {
      // backend returns { success: true, data: [ ...appointments ] }
      final data = response['data'];
      if (data is List) return data;
      // Fallback for any older shape
      if (response['appointments'] is Map && response['appointments']['docs'] is List) {
        return List<dynamic>.from(response['appointments']['docs']);
      }
      return <dynamic>[];
    }
    throw Exception(response['message'] ?? 'Failed to load appointments');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _appointmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có lịch hẹn nào.'));
        }

        final appointments = snapshot.data!;

        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            final patient = appointment['user'] ?? appointment['patient'];
            final date = appointment['date'];
            final startTime = appointment['startTime'];
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text('Bệnh nhân: ${patient?['fullName'] ?? 'N/A'}'),
                subtitle: Text(
                  'Ngày: ${date != null ? DateTime.tryParse(date)?.toLocal().toString().split(' ').first : 'N/A'}\n'
                  'Giờ: ${startTime ?? ''}\n'
                  'Lý do: ${appointment['reason'] ?? 'Không có lý do'}'
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(appointment['status'] ?? ''),
                    const SizedBox(height: 8),
                    if ((appointment['status'] ?? '').toLowerCase() == 'pending')
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Chấp nhận',
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () async {
                              try {
                                await AppointmentService.updateAppointmentStatus(
                                  appointmentId: appointment['_id'],
                                  status: 'confirmed',
                                );
                                setState(() { _appointmentsFuture = _fetchAppointments(); });
                              } catch (_) {}
                            },
                          ),
                          IconButton(
                            tooltip: 'Từ chối',
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () async {
                              try {
                                await AppointmentService.updateAppointmentStatus(
                                  appointmentId: appointment['_id'],
                                  status: 'cancelled',
                                );
                                setState(() { _appointmentsFuture = _fetchAppointments(); });
                              } catch (_) {}
                            },
                          ),
                        ],
                      ),
                  ],
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Chi tiết lịch hẹn'),
                      content: Text(
                        'Bệnh nhân: ${patient?['fullName'] ?? 'N/A'}\n'
                        'Ngày: ${date != null ? DateTime.tryParse(date)?.toLocal().toString().split(' ').first : 'N/A'}\n'
                        'Giờ: ${startTime ?? ''}\n'
                        'Lý do: ${appointment['reason'] ?? ''}\n'
                        'Trạng thái: ${appointment['status'] ?? ''}'
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
