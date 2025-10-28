import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class RoleTestPage extends ConsumerWidget {
  const RoleTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Roles'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin người dùng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Tên: ${user?.fullName ?? 'N/A'}'),
                    Text('Email: ${user?.email ?? 'N/A'}'),
                    Text('Role: ${user?.role ?? 'N/A'}'),
                    Text('Trạng thái: ${authState.isAuthenticated ? 'Đã đăng nhập' : 'Chưa đăng nhập'}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Role-based Navigation
            Text(
              'Điều hướng theo vai trò',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            
            if (user?.role == 'user') ...[
              _buildNavigationCard(
                context,
                'Dashboard User',
                'Trang chủ cho người dùng',
                Icons.dashboard,
                Colors.blue,
                '/dashboard',
              ),
              _buildNavigationCard(
                context,
                'Tìm kiếm thuốc',
                'Tra cứu thông tin thuốc',
                Icons.search,
                Colors.green,
                '/drugs',
              ),
              _buildNavigationCard(
                context,
                'Đặt lịch hẹn',
                'Đặt lịch khám với bác sĩ',
                Icons.calendar_today,
                Colors.orange,
                '/create-appointment',
              ),
              _buildNavigationCard(
                context,
                'Chat với bác sĩ',
                'Trò chuyện với bác sĩ',
                Icons.chat,
                Colors.purple,
                '/chat',
              ),
            ],
            
            if (user?.role == 'doctor') ...[
              _buildNavigationCard(
                context,
                'Dashboard Bác sĩ',
                'Trang quản lý cho bác sĩ',
                Icons.medical_services,
                Colors.green,
                '/doctor/dashboard',
              ),
            ],
            
            if (user?.role == 'pharmacist') ...[
              _buildNavigationCard(
                context,
                'Dashboard Dược sĩ',
                'Trang quản lý cho dược sĩ',
                Icons.local_pharmacy,
                Colors.blue,
                '/pharmacist/dashboard',
              ),
              _buildNavigationCard(
                context,
                'Quản lý sản phẩm',
                'Thêm, sửa, xóa sản phẩm thuốc',
                Icons.medication,
                Colors.green,
                '/pharmacist/products',
              ),
              _buildNavigationCard(
                context,
                'Quản lý danh mục',
                'Quản lý danh mục thuốc',
                Icons.category,
                Colors.orange,
                '/pharmacist/categories',
              ),
              _buildNavigationCard(
                context,
                'QR Scanner',
                'Quét mã QR thuốc',
                Icons.qr_code_scanner,
                Colors.purple,
                '/pharmacist/qr-scanner',
              ),
            ],
            
            if (user?.role == 'admin') ...[
              _buildNavigationCard(
                context,
                'Dashboard Admin',
                'Trang quản lý hệ thống',
                Icons.admin_panel_settings,
                Colors.red,
                '/admin/dashboard',
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Test Actions
            Text(
              'Hành động test',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    String route,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          context.go(route);
        },
      ),
    );
  }
}
