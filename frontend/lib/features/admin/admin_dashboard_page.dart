import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _DashboardOverview(),
    const _UserManagement(),
    const _DoctorApproval(),
    const _ProductMonitoring(),
    const _SystemConfig(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Tổng quan'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                selectedIcon: Icon(Icons.people),
                label: Text('Quản lý người dùng'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.medical_services),
                selectedIcon: Icon(Icons.medical_services),
                label: Text('Duyệt bác sĩ'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.medication),
                selectedIcon: Icon(Icons.medication),
                label: Text('Giám sát thuốc'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                selectedIcon: Icon(Icons.settings),
                label: Text('Cấu hình hệ thống'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main content
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

class _DashboardOverview extends StatelessWidget {
  const _DashboardOverview();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan hệ thống',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 24),
          
          // Summary Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildSummaryCard(
                'Tổng người dùng',
                '1,234',
                Icons.people,
                Colors.blue,
              ),
              _buildSummaryCard(
                'Bác sĩ',
                '56',
                Icons.medical_services,
                Colors.green,
              ),
              _buildSummaryCard(
                'Dược sĩ',
                '23',
                Icons.local_pharmacy,
                Colors.orange,
              ),
              _buildSummaryCard(
                'Sản phẩm',
                '2,456',
                Icons.medication,
                Colors.purple,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Recent Activities
          Text(
            'Hoạt động gần đây',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: ListView(
              children: [
                _buildActivityItem(
                  'Người dùng mới đăng ký',
                  'user@example.com',
                  '2 phút trước',
                  Icons.person_add,
                  Colors.blue,
                ),
                _buildActivityItem(
                  'Bác sĩ chờ duyệt',
                  'Dr. Nguyen Van A',
                  '15 phút trước',
                  Icons.pending,
                  Colors.orange,
                ),
                _buildActivityItem(
                  'Sản phẩm mới',
                  'Paracetamol 500mg',
                  '1 giờ trước',
                  Icons.add_circle,
                  Colors.green,
                ),
                _buildActivityItem(
                  'Báo cáo spam',
                  'Chat conversation #123',
                  '2 giờ trước',
                  Icons.report,
                  Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          time,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

class _UserManagement extends StatelessWidget {
  const _UserManagement();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Quản lý người dùng',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement user search/filter
                },
                icon: const Icon(Icons.search),
                label: const Text('Tìm kiếm'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Filter bar
                    Row(
                      children: [
                        DropdownButton<String>(
                          value: 'all',
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('Tất cả vai trò')),
                            DropdownMenuItem(value: 'user', child: Text('Người dùng')),
                            DropdownMenuItem(value: 'doctor', child: Text('Bác sĩ')),
                            DropdownMenuItem(value: 'pharmacist', child: Text('Dược sĩ')),
                            DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          ],
                          onChanged: (value) {
                            // TODO: Implement filter
                          },
                        ),
                        const SizedBox(width: 16),
                        DropdownButton<String>(
                          value: 'all',
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('Tất cả trạng thái')),
                            DropdownMenuItem(value: 'active', child: Text('Hoạt động')),
                            DropdownMenuItem(value: 'locked', child: Text('Bị khóa')),
                            DropdownMenuItem(value: 'pending', child: Text('Chờ duyệt')),
                          ],
                          onChanged: (value) {
                            // TODO: Implement filter
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Users table
                    Expanded(
                      child: ListView(
                        children: [
                          _buildUserItem(
                            'Nguyễn Văn A',
                            'user@example.com',
                            'Người dùng',
                            'Hoạt động',
                            Colors.green,
                          ),
                          _buildUserItem(
                            'Dr. Trần Thị B',
                            'doctor@example.com',
                            'Bác sĩ',
                            'Chờ duyệt',
                            Colors.orange,
                          ),
                          _buildUserItem(
                            'Dược sĩ Lê Văn C',
                            'pharmacist@example.com',
                            'Dược sĩ',
                            'Hoạt động',
                            Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(String name, String email, String role, String status, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: Text(name[0]),
        ),
        title: Text(name),
        subtitle: Text('$email • $role'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                // TODO: Implement user actions
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('Xem chi tiết'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Chỉnh sửa'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'lock',
                  child: Row(
                    children: [
                      Icon(Icons.lock, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Khóa tài khoản', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorApproval extends StatelessWidget {
  const _DoctorApproval();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Duyệt hồ sơ bác sĩ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView(
              children: [
                _buildDoctorApprovalCard(
                  'Dr. Nguyễn Văn A',
                  'Chuyên khoa Tim mạch',
                  'Giấy phép: DOC123456',
                  'Đã xác minh',
                  Colors.green,
                  true,
                ),
                _buildDoctorApprovalCard(
                  'Dr. Trần Thị B',
                  'Chuyên khoa Nhi',
                  'Giấy phép: DOC789012',
                  'Chờ xác minh',
                  Colors.orange,
                  false,
                ),
                _buildDoctorApprovalCard(
                  'Dr. Lê Văn C',
                  'Chuyên khoa Da liễu',
                  'Giấy phép: DOC345678',
                  'Chờ xác minh',
                  Colors.orange,
                  false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorApprovalCard(String name, String specialty, String license, String status, Color statusColor, bool isApproved) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[300],
                  child: Text(name.split(' ').last[0]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(specialty),
                      Text(license),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isApproved ? null : () {
                      // TODO: Implement approve
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Duyệt'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement reject
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Từ chối'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement view details
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Chi tiết'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductMonitoring extends StatelessWidget {
  const _ProductMonitoring();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giám sát dữ liệu thuốc',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView(
              children: [
                _buildProductCard(
                  'Paracetamol 500mg',
                  'Thuốc giảm đau, hạ sốt',
                  'Chờ duyệt',
                  Colors.orange,
                ),
                _buildProductCard(
                  'Amoxicillin 250mg',
                  'Kháng sinh',
                  'Đã duyệt',
                  Colors.green,
                ),
                _buildProductCard(
                  'Vitamin C 1000mg',
                  'Bổ sung vitamin',
                  'Bị từ chối',
                  Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(String name, String description, String status, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medication, color: Colors.blue[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(description),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement approve
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Duyệt'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement reject
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Từ chối'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement view details
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Chi tiết'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemConfig extends StatelessWidget {
  const _SystemConfig();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cấu hình hệ thống',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView(
              children: [
                _buildConfigItem(
                  'Tên hệ thống',
                  'HealthCare App',
                  Icons.apps,
                ),
                _buildConfigItem(
                  'Email liên hệ',
                  'admin@healthcare.com',
                  Icons.email,
                ),
                _buildConfigItem(
                  'Số điện thoại',
                  '0123456789',
                  Icons.phone,
                ),
                _buildConfigItem(
                  'Chế độ bảo trì',
                  'Tắt',
                  Icons.build,
                ),
                _buildConfigItem(
                  'Cho phép đăng ký',
                  'Bật',
                  Icons.person_add,
                ),
                _buildConfigItem(
                  'Xác minh email',
                  'Bắt buộc',
                  Icons.verified_user,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement save config
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Lưu cấu hình'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement reset config
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Khôi phục mặc định'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigItem(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[600]),
        title: Text(title),
        subtitle: Text(value),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // TODO: Implement edit config
          },
        ),
      ),
    );
  }
}
