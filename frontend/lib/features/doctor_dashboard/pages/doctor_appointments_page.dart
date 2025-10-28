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
    if (response['success'] && response['appointments'] != null) {
      return response['appointments']['docs'];
    } else {
      throw Exception(response['message'] ?? 'Failed to load appointments');
    }
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
            final patient = appointment['patient']; // Assuming patient info is populated
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text('Bệnh nhân: ${patient?['fullName'] ?? 'N/A'}'),
                subtitle: Text('Lý do: ${appointment['reason'] ?? 'Không có lý do'}'),
                trailing: Text(appointment['status'] ?? ''),
              ),
            );
          },
        );
      },
    );
  }
}
