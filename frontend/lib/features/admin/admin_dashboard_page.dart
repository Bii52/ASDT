import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/admin_service.dart';
import '../../services/product_service.dart';
import '../../services/auth_service.dart';

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
    const _AdminProductCrud(),
    const _SystemConfig(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          )
        ],
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
                icon: Icon(Icons.inventory_2),
                selectedIcon: Icon(Icons.inventory_2),
                label: Text('CRUD thuốc'),
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
      child: FutureBuilder<Map<String, dynamic>>(
        future: AdminService.getDashboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?['success'] != true) {
            return Center(
              child: Text(
                snapshot.data?['message'] ?? 'Không thể tải dashboard',
                style: TextStyle(color: Colors.red[700]),
              ),
            );
          }
          final data = snapshot.data!['data'] as Map<String, dynamic>;
          final summary = data['summary'] as Map<String, dynamic>;
          final recentUsers = List<Map<String, dynamic>>.from(data['recentUsers'] ?? []);
          final recentDoctors = List<Map<String, dynamic>>.from(data['recentDoctors'] ?? []);

          return Column(
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
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildSummaryCard('Tổng người dùng', '${summary['totalUsers']}', Icons.people, Colors.blue),
                  _buildSummaryCard('Bác sĩ', '${summary['totalDoctors']}', Icons.medical_services, Colors.green),
                  _buildSummaryCard('Dược sĩ', '${summary['totalPharmacists']}', Icons.local_pharmacy, Colors.orange),
                  _buildSummaryCard('Sản phẩm', '${summary['totalProducts']}', Icons.medication, Colors.purple),
                ],
              ),
              const SizedBox(height: 32),
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
                    for (final u in recentUsers)
                      _buildActivityItem('Người dùng mới đăng ký', u['email'] ?? '', '', Icons.person_add, Colors.blue),
                    for (final d in recentDoctors)
                      _buildActivityItem('Bác sĩ mới', (d['fullName'] ?? ''), (d['specialty'] ?? ''), Icons.medical_services, Colors.green),
                  ],
                ),
              ),
            ],
          );
        },
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

class _UserManagement extends StatefulWidget {
  const _UserManagement();

  @override
  State<_UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<_UserManagement> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _role = 'all';
  String _status = 'all'; // all, active, locked, inactive_email
  int _page = 1;
  int _limit = 20;

  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadUsers();
  }

  Future<Map<String, dynamic>> _loadUsers() {
    // Map status filters
    bool? emailVerified;
    bool? isLocked;
    if (_status == 'inactive_email') emailVerified = false;
    if (_status == 'locked') isLocked = true;
    if (_status == 'active') { emailVerified = true; isLocked = false; }
    return AdminService.getUsers(
      page: _page,
      limit: _limit,
      role: _role == 'all' ? null : _role,
      emailVerified: emailVerified,
      isLocked: isLocked,
      q: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
    );
  }

  void _applyFilters() {
    setState(() {
      _page = 1;
      _future = _loadUsers();
    });
  }

  void _goPage(int delta) {
    setState(() {
      _page = (_page + delta).clamp(1, 1000000);
      _future = _loadUsers();
    });
  }

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
              FilledButton.icon(
                onPressed: _openCreateDoctorDialog,
                icon: const Icon(Icons.add),
                label: const Text('Thêm bác sĩ mới'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Horizontal filter bar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 260,
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Tìm theo tên hoặc email',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onSubmitted: (_) => _applyFilters(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _role,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Tất cả vai trò')),
                        DropdownMenuItem(value: 'user', child: Text('Người dùng')),
                        DropdownMenuItem(value: 'doctor', child: Text('Bác sĩ')),
                        DropdownMenuItem(value: 'pharmacist', child: Text('Dược sĩ')),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      ],
                      onChanged: (v) { if (v != null) setState(() => _role = v); },
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _status,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Tất cả trạng thái')),
                        DropdownMenuItem(value: 'active', child: Text('Hoạt động')),
                        DropdownMenuItem(value: 'locked', child: Text('Bị khóa')),
                        DropdownMenuItem(value: 'inactive_email', child: Text('Chưa xác minh email')),
                      ],
                      onChanged: (v) { if (v != null) setState(() => _status = v); },
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: _limit,
                      items: const [10, 20, 50, 100]
                          .map((e) => DropdownMenuItem(value: e, child: Text('Hiển thị $e')))
                          .toList(),
                      onChanged: (v) { if (v != null) setState(() => _limit = v); },
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _applyFilters,
                      icon: const Icon(Icons.filter_alt),
                      label: const Text('Lọc'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: _future,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data?['success'] != true) {
                            return Center(
                              child: Text(
                                snapshot.data?['message'] ?? 'Không thể tải người dùng',
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            );
                          }
                          final result = snapshot.data!['data'] as Map<String, dynamic>;
                          final users = List<Map<String, dynamic>>.from(result['docs'] ?? []);
                          if (users.isEmpty) {
                            return const Center(child: Text('Không có người dùng'));
                          }
                          return ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final u = users[index];
                              final name = (u['fullName'] ?? '---').toString();
                              final email = (u['email'] ?? '').toString();
                              final role = (u['role'] ?? '').toString();
                              final isLocked = u['isLocked'] == true;
                              final emailVerified = u['emailVerified'] == true;
                              final status = isLocked
                                  ? 'Bị khóa'
                                  : (emailVerified ? 'Hoạt động' : 'Chưa xác minh');
                              final statusColor = isLocked
                                  ? Colors.red
                                  : (emailVerified ? Colors.green : Colors.orange);
                              return _buildUserItem(u, name, email, role, status, statusColor);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Trang trước',
                          onPressed: _page > 1 ? () => _goPage(-1) : null,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text('Trang $_page'),
                        IconButton(
                          tooltip: 'Trang sau',
                          onPressed: () => _goPage(1),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
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

  Widget _buildUserItem(Map<String, dynamic> user, String name, String email, String role, String status, Color statusColor) {
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
              onSelected: (value) async {
                if (value == 'view') {
                  _showUserDetailDialog(context, user);
                } else if (value == 'lock') {
                  final reason = await _promptReason(context, title: 'Lý do khóa tài khoản');
                  if (reason == null || reason.isEmpty) return;
                  final res = await AdminService.lockUser(user['_id'], reason);
                  if (mounted) {
                    if (res['success'] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã khóa tài khoản')));
                      _applyFilters();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Khóa thất bại')));
                    }
                  }
                } else if (value == 'unlock') {
                  final res = await AdminService.unlockUser(user['_id']);
                  if (mounted) {
                    if (res['success'] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã mở khóa tài khoản')));
                      _applyFilters();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Mở khóa thất bại')));
                    }
                  }
                }
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
                if (user['isLocked'] == true)
                  const PopupMenuItem(
                    value: 'unlock',
                    child: Row(
                      children: [
                        Icon(Icons.lock_open, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Mở khóa tài khoản', style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  )
                else
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

  Future<void> _showUserDetailDialog(BuildContext context, Map<String, dynamic> user) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chi tiết người dùng'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Họ tên: ${user['fullName'] ?? ''}')
                  ,
              Text('Email: ${user['email'] ?? ''}')
                  ,
              Text('Vai trò: ${user['role'] ?? ''}')
                  ,
              Text('Xác minh email: ${(user['emailVerified'] == true) ? 'Đã xác minh' : 'Chưa xác minh'}')
                  ,
              if (user['isLocked'] == true) ...[
                const SizedBox(height: 8),
                const Text('Trạng thái: Bị khóa', style: TextStyle(color: Colors.red)),
                if (user['lockReason'] != null) Text('Lý do: ${user['lockReason']}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }

  Future<void> _openCreateDoctorDialog() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final specialtyCtrl = TextEditingController();
    final licenseCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm bác sĩ mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Họ tên')),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Mật khẩu'), obscureText: true),
              TextField(controller: specialtyCtrl, decoration: const InputDecoration(labelText: 'Chuyên khoa')),
              TextField(controller: licenseCtrl, decoration: const InputDecoration(labelText: 'Số giấy phép')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          FilledButton(
            onPressed: () async {
              final payload = {
                'fullName': nameCtrl.text.trim(),
                'email': emailCtrl.text.trim(),
                'password': passCtrl.text.trim(),
                'specialty': specialtyCtrl.text.trim(),
                'licenseNumber': licenseCtrl.text.trim(),
              };
              final res = await AdminService.createDoctor(payload);
              if (!mounted) return;
              if (res['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm bác sĩ')));
                Navigator.pop(context);
                _applyFilters();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Thêm bác sĩ thất bại')));
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}

class _DoctorApproval extends StatefulWidget {
  const _DoctorApproval();
  @override
  State<_DoctorApproval> createState() => _DoctorApprovalState();
}

class _DoctorApprovalState extends State<_DoctorApproval> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = AdminService.getPendingDoctors();
  }

  void _refresh() {
    setState(() { _future = AdminService.getPendingDoctors(); });
  }

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
            child: FutureBuilder<Map<String, dynamic>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data?['success'] != true) {
                  return Center(
                    child: Text(
                      snapshot.data?['message'] ?? 'Không thể tải danh sách bác sĩ',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  );
                }
                final doctors = List<Map<String, dynamic>>.from(snapshot.data!['data'] ?? []);
                if (doctors.isEmpty) {
                  return const Center(child: Text('Không có bác sĩ chờ duyệt'));
                }
                return ListView.builder(
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final d = doctors[index];
                    return _buildDoctorApprovalCard(
                      context,
                      d['_id'] ?? '',
                      (d['fullName'] ?? ''),
                      (d['specialty'] ?? ''),
                      'Giấy phép: ${d['licenseNumber'] ?? ''}',
                      (d['doctorStatus'] ?? 'pending'),
                      (d['doctorStatus'] == 'approved'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorApprovalCard(BuildContext context, String id, String name, String specialty, String license, String status, bool isApproved) {
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
                    color: (isApproved ? Colors.green : Colors.orange).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isApproved ? Colors.green : Colors.orange,
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
                    onPressed: isApproved ? null : () async {
                      final res = await AdminService.approveDoctor(id, {
                        'approvedBy': '000000000000000000000000',
                        'notes': 'Approved by admin UI'
                      });
                      if (res['success'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã duyệt bác sĩ')));
                        _refresh();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Lỗi duyệt bác sĩ')));
                      }
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
                    onPressed: () async {
                      final reason = await _promptReason(context, title: 'Lý do từ chối');
                      if (reason == null || reason.isEmpty) return;
                      final res = await AdminService.rejectDoctor(id, reason);
                      if (res['success'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã từ chối bác sĩ')));
                        _refresh();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Lỗi từ chối bác sĩ')));
                      }
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

class _ProductMonitoring extends StatefulWidget {
  const _ProductMonitoring();
  @override
  State<_ProductMonitoring> createState() => _ProductMonitoringState();
}

class _ProductMonitoringState extends State<_ProductMonitoring> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = AdminService.getProductsForReview(page: 1, limit: 20);
  }

  void _refresh() {
    setState(() { _future = AdminService.getProductsForReview(page: 1, limit: 20); });
  }

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
            child: FutureBuilder<Map<String, dynamic>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data?['success'] != true) {
                  return Center(
                    child: Text(
                      snapshot.data?['message'] ?? 'Không thể tải sản phẩm',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  );
                }
                final result = snapshot.data!['data'] as Map<String, dynamic>;
                final products = List<Map<String, dynamic>>.from(result['docs'] ?? []);
                if (products.isEmpty) {
                  return const Center(child: Text('Không có sản phẩm chờ duyệt'));
                }
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return _buildProductCard(context, p);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> p) {
    final name = (p['name'] ?? '').toString();
    final description = (p['description'] ?? '').toString();
    final approved = p['adminApproved'] == true;
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
                    color: (approved ? Colors.green : Colors.orange).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    approved ? 'Đã duyệt' : 'Chờ duyệt',
                    style: TextStyle(
                      color: approved ? Colors.green : Colors.orange,
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
                    onPressed: approved ? null : () async {
                      final res = await AdminService.approveProduct(p['_id']);
                      if (res['success'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã duyệt sản phẩm')));
                        _refresh();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Lỗi duyệt sản phẩm')));
                      }
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
                    onPressed: () async {
                      final reason = await _promptReason(context, title: 'Lý do từ chối');
                      if (reason == null || reason.isEmpty) return;
                      final res = await AdminService.rejectProduct(p['_id'], reason);
                      if (res['success'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã từ chối sản phẩm')));
                        _refresh();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Lỗi từ chối sản phẩm')));
                      }
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

class _SystemConfig extends StatefulWidget {
  const _SystemConfig();

  @override
  State<_SystemConfig> createState() => _SystemConfigState();
}

class _SystemConfigState extends State<_SystemConfig> {
  final _siteNameCtrl = TextEditingController();
  final _siteDescCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _maintenanceMode = false;
  bool _allowRegistration = true;
  bool _requireEmailVerification = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; });
    final res = await AdminService.getSystemConfig();
    if (res['success'] == true) {
      final cfg = res['data'] as Map<String, dynamic>;
      _siteNameCtrl.text = (cfg['siteName'] ?? '').toString();
      _siteDescCtrl.text = (cfg['siteDescription'] ?? '').toString();
      _emailCtrl.text = (cfg['contactEmail'] ?? '').toString();
      _phoneCtrl.text = (cfg['contactPhone'] ?? '').toString();
      _maintenanceMode = cfg['maintenanceMode'] == true;
      _allowRegistration = cfg['allowRegistration'] == true;
      _requireEmailVerification = cfg['requireEmailVerification'] == true;
    }
    if (mounted) setState(() { _loading = false; });
  }

  Future<void> _save() async {
    final payload = {
      'siteName': _siteNameCtrl.text.trim(),
      'siteDescription': _siteDescCtrl.text.trim(),
      'contactEmail': _emailCtrl.text.trim(),
      'contactPhone': _phoneCtrl.text.trim(),
      'maintenanceMode': _maintenanceMode,
      'allowRegistration': _allowRegistration,
      'requireEmailVerification': _requireEmailVerification,
    };
    final res = await AdminService.updateSystemConfig(payload);
    if (!mounted) return;
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu cấu hình')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Lưu thất bại')));
    }
  }

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
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextField(controller: _siteNameCtrl, decoration: const InputDecoration(labelText: 'Tên hệ thống')),
                              TextField(controller: _siteDescCtrl, decoration: const InputDecoration(labelText: 'Mô tả')), 
                              TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email liên hệ')),
                              TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Số điện thoại')),
                              const SizedBox(height: 12),
                              SwitchListTile(
                                value: _maintenanceMode,
                                onChanged: (v) => setState(() => _maintenanceMode = v),
                                title: const Text('Chế độ bảo trì'),
                              ),
                              SwitchListTile(
                                value: _allowRegistration,
                                onChanged: (v) => setState(() => _allowRegistration = v),
                                title: const Text('Cho phép đăng ký'),
                              ),
                              SwitchListTile(
                                value: _requireEmailVerification,
                                onChanged: (v) => setState(() => _requireEmailVerification = v),
                                title: const Text('Yêu cầu xác minh email'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _save,
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
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tải lại'),
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
}

Future<String?> _promptReason(BuildContext context, {required String title}) async {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        minLines: 1,
        maxLines: 3,
        decoration: const InputDecoration(hintText: 'Nhập lý do'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Xác nhận')),
      ],
    ),
  );
}

class _AdminProductCrud extends StatefulWidget {
  const _AdminProductCrud();
  @override
  State<_AdminProductCrud> createState() => _AdminProductCrudState();
}

class _AdminProductCrudState extends State<_AdminProductCrud> {
  late Future<Map<String, dynamic>> _future;
  final TextEditingController _searchCtrl = TextEditingController();
  String? _categoryId;
  int _page = 1;
  int _limit = 20;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _future = _loadProducts();
    _loadCategories();
  }

  void _refresh() {
    setState(() { _future = _loadProducts(); });
  }

  Future<void> _loadCategories() async {
    final catRes = await ProductService.getCategories();
    if (catRes['success'] == true) {
      final data = catRes['data'];
      if (data is Map && data['docs'] is List) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(data['docs']);
        });
      }
    }
  }

  Future<Map<String, dynamic>> _loadProducts() {
    return ProductService.getProducts(
      name: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      category: _categoryId,
      page: _page,
      limit: _limit,
      sortBy: '-createdAt',
    );
  }

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
                'Quản lý thuốc (CRUD)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
              const Spacer(),
              SizedBox(
                width: 260,
                child: TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Tìm theo tên thuốc',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _refresh(),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String?>(
                value: _categoryId,
                hint: const Text('Danh mục'),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('Tất cả danh mục')),
                  ..._categories.map((c) => DropdownMenuItem<String?>(
                        value: c['_id'] as String?,
                        child: Text((c['name'] ?? '').toString()),
                      )),
                ],
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: _limit,
                items: const [10, 20, 50, 100]
                    .map((e) => DropdownMenuItem(value: e, child: Text('Hiển thị $e')))
                    .toList(),
                onChanged: (v) { if (v != null) setState(() => _limit = v); },
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () { _page = 1; _refresh(); },
                icon: const Icon(Icons.filter_alt),
                label: const Text('Lọc'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => _openEditDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Thêm thuốc'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data?['success'] != true) {
                  return Center(child: Text(snapshot.data?['message'] ?? 'Không thể tải thuốc'));
                }
                final map = snapshot.data!['data'] as Map<String, dynamic>;
                final docs = List<Map<String, dynamic>>.from(map['docs'] ?? []);
                if (docs.isEmpty) return const Center(child: Text('Chưa có thuốc'));
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final p = docs[index];
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.medication_outlined),
                              title: Text(p['name'] ?? ''),
                              subtitle: Text('Giá: ${p['referencePrice'] ?? 'N/A'} • Danh mục: ${p['category'] is Map ? (p['category']['name'] ?? '') : (p['category'] ?? '')}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Sửa',
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _openEditDialog(context, product: p),
                                  ),
                                  IconButton(
                                    tooltip: 'Xóa',
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Xóa thuốc'),
                                          content: Text('Bạn chắc chắn muốn xóa "${p['name'] ?? ''}"?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
                                            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        final res = await ProductService.deleteProduct(p['_id']);
                                        if (res['success'] == true) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa')));
                                          _refresh();
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Xóa thất bại')));
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Trang trước',
                          onPressed: _page > 1 ? () { setState(() { _page -= 1; _refresh(); }); } : null,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text('Trang $_page'),
                        IconButton(
                          tooltip: 'Trang sau',
                          onPressed: () { setState(() { _page += 1; _refresh(); }); },
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditDialog(BuildContext context, {Map<String, dynamic>? product}) async {
    final nameCtrl = TextEditingController(text: product?['name'] ?? '');
    final imgCtrl = TextEditingController(text: product?['image'] ?? '');
    final usesCtrl = TextEditingController(text: product?['uses'] ?? '');
    final priceCtrl = TextEditingController(text: (product?['referencePrice'] ?? '').toString());
    final dynamic catField = product?['category'];
    String? selectedCategoryId = catField is Map
        ? (catField['_id'] as String?)
        : (catField as String?);

    List<Map<String, dynamic>> categories = [];
    final catRes = await ProductService.getCategories();
    if (catRes['success'] == true) {
      final data = catRes['data'];
      if (data is Map && data['docs'] is List) {
        categories = List<Map<String, dynamic>>.from(data['docs']);
      }
    }

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(product == null ? 'Thêm thuốc' : 'Sửa thuốc'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên thuốc')),
                TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'Ảnh (URL)')),
                TextField(controller: usesCtrl, decoration: const InputDecoration(labelText: 'Công dụng')), 
                TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Giá tham khảo'), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                  items: [
                    for (final c in categories)
                      DropdownMenuItem(value: (c['_id'] as String?), child: Text((c['name'] ?? '').toString())),
                  ],
                  onChanged: (v) => setSt(() => selectedCategoryId = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            FilledButton(
              onPressed: () async {
                final payload = {
                  'name': nameCtrl.text.trim(),
                  'image': imgCtrl.text.trim(),
                  'uses': usesCtrl.text.trim(),
                  'referencePrice': double.tryParse(priceCtrl.text.trim()) ?? 0.0,
                  'category': selectedCategoryId ?? '',
                };
                Map<String, dynamic> res;
                if (product == null) {
                  res = await ProductService.createProduct(payload);
                } else {
                  res = await ProductService.updateProduct(product['_id'], payload);
                }
                if (res['success'] == true) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu thành công')));
                    Navigator.pop(ctx);
                    _refresh();
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Lưu thất bại')));
                  }
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}
