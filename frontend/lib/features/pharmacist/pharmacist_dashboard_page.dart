import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/pharmacist_service.dart';
import 'product_management_page.dart';
import 'category_management_page.dart';
import 'qr_scanner_page.dart';
import 'data_sync_page.dart';

class PharmacistDashboardPage extends ConsumerStatefulWidget {
  const PharmacistDashboardPage({super.key});

  @override
  ConsumerState<PharmacistDashboardPage> createState() => _PharmacistDashboardPageState();
}

class _PharmacistDashboardPageState extends ConsumerState<PharmacistDashboardPage> {
  int _selectedIndex = 0;
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await PharmacistService.getDashboard();
      if (result['success'] == true) {
        setState(() {
          dashboardData = result['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = result['message'] ?? 'Lỗi khi tải dashboard';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Lỗi kết nối: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _DashboardOverview(dashboardData: dashboardData, isLoading: isLoading, error: error, onRefresh: _loadDashboard),
      const ProductManagementPage(),
      const CategoryManagementPage(),
      const QRScannerPage(),
      const DataSyncPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Dược sĩ'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Sản phẩm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Danh mục',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'QR Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sync),
            label: 'Đồng bộ',
          ),
        ],
      ),
    );
  }

}

class _DashboardOverview extends StatelessWidget {
  final Map<String, dynamic>? dashboardData;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;

  const _DashboardOverview({
    required this.dashboardData,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              error!,
              style: TextStyle(color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    
    if (dashboardData == null) {
      return const Center(child: Text('Không có dữ liệu'));
    }

    final pharmacist = dashboardData!['pharmacist'];
    final summary = dashboardData!['summary'];
    final recentProducts = dashboardData!['recentProducts'] as List<dynamic>?;
    final lowStockProducts = dashboardData!['lowStockProducts'] as List<dynamic>?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pharmacy Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_pharmacy, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Thông tin nhà thuốc',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Tên nhà thuốc: ${pharmacist['pharmacyName'] ?? 'Chưa cập nhật'}'),
                  Text('Địa chỉ: ${pharmacist['pharmacyAddress'] ?? 'Chưa cập nhật'}'),
                  Text('Dược sĩ: ${pharmacist['fullName']}'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Summary Cards
          Text(
            'Tổng quan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildSummaryCard(
                'Danh mục',
                summary['totalCategories'].toString(),
                Icons.category,
                Colors.blue,
              ),
              _buildSummaryCard(
                'Sản phẩm',
                summary['totalProducts'].toString(),
                Icons.medication,
                Colors.green,
              ),
              _buildSummaryCard(
                'Còn hàng',
                summary['inStockProducts'].toString(),
                Icons.check_circle,
                Colors.green,
              ),
              _buildSummaryCard(
                'Hết hàng',
                summary['outOfStockProducts'].toString(),
                Icons.cancel,
                Colors.red,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent Products
          if (recentProducts != null && recentProducts.isNotEmpty) ...[
            Text(
              'Sản phẩm mới',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            ...recentProducts.map((product) => _buildProductCard(product, isRecent: true)),
          ],
          
          const SizedBox(height: 24),
          
          // Low Stock Products
          if (lowStockProducts != null && lowStockProducts.isNotEmpty) ...[
            Text(
              'Sản phẩm sắp hết hàng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange[600],
              ),
            ),
            const SizedBox(height: 12),
            ...lowStockProducts.map((product) => _buildProductCard(product, isLowStock: true)),
          ],
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

  Widget _buildProductCard(Map<String, dynamic> product, {bool isRecent = false, bool isLowStock = false}) {
    Color cardColor = Colors.white;
    IconData? icon;
    Color? iconColor;
    
    if (isLowStock) {
      cardColor = Colors.orange[50]!;
      icon = Icons.warning;
      iconColor = Colors.orange[600];
    } else if (isRecent) {
      cardColor = Colors.blue[50]!;
      icon = Icons.new_releases;
      iconColor = Colors.blue[600];
    }

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: icon != null
            ? Icon(icon, color: iconColor)
            : Icon(Icons.medication, color: Colors.grey[600]),
        title: Text(
          product['name'] ?? 'Không có tên',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Giá: ${product['price']?.toString() ?? 'N/A'} VNĐ'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tồn kho: ${product['inStock']?.toString() ?? '0'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: (product['inStock'] ?? 0) <= 10 ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to product detail
        },
      ),
    );
  }
}
