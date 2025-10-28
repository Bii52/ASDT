import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/pharmacist_service.dart';

class PharmacistStatsPage extends ConsumerStatefulWidget {
  const PharmacistStatsPage({super.key});

  @override
  ConsumerState<PharmacistStatsPage> createState() => _PharmacistStatsPageState();
}

class _PharmacistStatsPageState extends ConsumerState<PharmacistStatsPage> {
  String selectedPeriod = 'month';
  String? selectedCategory;
  Map<String, dynamic>? statsData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await PharmacistService.getBestsellingStats(
        period: selectedPeriod,
        category: selectedCategory,
      );
      
      if (result['success'] == true) {
        setState(() {
          statsData = result['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = result['message'] ?? 'Lỗi khi tải thống kê';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê thuốc bán chạy'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Thời gian',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedPeriod,
                    items: const [
                      DropdownMenuItem(value: 'week', child: Text('Tuần')),
                      DropdownMenuItem(value: 'month', child: Text('Tháng')),
                      DropdownMenuItem(value: 'year', child: Text('Năm')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedPeriod = value!;
                      });
                      _loadStats();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Danh mục',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedCategory,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Tất cả danh mục'),
                      ),
                      // TODO: Load categories from API
                      const DropdownMenuItem(value: 'antibiotics', child: Text('Kháng sinh')),
                      const DropdownMenuItem(value: 'painkillers', child: Text('Giảm đau')),
                      const DropdownMenuItem(value: 'vitamins', child: Text('Vitamin')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                      _loadStats();
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Stats Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(
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
                              onPressed: _loadStats,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : statsData != null
                        ? _buildStatsContent()
                        : const Center(child: Text('Không có dữ liệu')),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent() {
    final stats = statsData!['stats'] as List<dynamic>? ?? [];
    
    if (stats.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có dữ liệu thống kê',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Text(
            'Tổng quan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildSummaryCard(
                'Tổng sản phẩm',
                stats.fold<int>(0, (sum, stat) => sum + (stat['totalProducts'] as int? ?? 0)).toString(),
                Icons.medication,
                Colors.blue,
              ),
              _buildSummaryCard(
                'Giá trị tồn kho',
                '${stats.fold<double>(0, (sum, stat) => sum + (stat['totalValue'] as double? ?? 0)).toStringAsFixed(0)} VNĐ',
                Icons.attach_money,
                Colors.green,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Chart
          Text(
            'Biểu đồ theo danh mục',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            height: 300,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: stats.isNotEmpty 
                        ? stats.map((e) => e['totalProducts'] as double? ?? 0).reduce((a, b) => a > b ? a : b) * 1.2
                        : 100,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.blueGrey,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final stat = stats[groupIndex];
                          return BarTooltipItem(
                            '${stat['categoryName']}\n${stat['totalProducts']} sản phẩm',
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            if (value.toInt() < stats.length) {
                              final stat = stats[value.toInt()];
                              final categoryName = stat['categoryName'] as String? ?? 'N/A';
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  categoryName.length > 8 
                                      ? '${categoryName.substring(0, 8)}...'
                                      : categoryName,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: stats.asMap().entries.map((entry) {
                      final index = entry.key;
                      final stat = entry.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: stat['totalProducts'] as double? ?? 0,
                            color: _getBarColor(index),
                            width: 20,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Detailed Stats Table
          Text(
            'Chi tiết theo danh mục',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Column(
              children: [
                ...stats.map((stat) => _buildStatRow(stat)),
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
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

  Widget _buildStatRow(Map<String, dynamic> stat) {
    final categoryName = stat['categoryName'] as String? ?? 'N/A';
    final totalProducts = stat['totalProducts'] as int? ?? 0;
    final averagePrice = stat['averagePrice'] as double? ?? 0;
    final totalValue = stat['totalValue'] as double? ?? 0;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.purple[300],
        child: Icon(Icons.category, color: Colors.purple[700]),
      ),
      title: Text(
        categoryName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Số sản phẩm: $totalProducts'),
          Text('Giá trung bình: ${averagePrice.toStringAsFixed(0)} VNĐ'),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${totalValue.toStringAsFixed(0)} VNĐ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          Text(
            'Tổng giá trị',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBarColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }
}
