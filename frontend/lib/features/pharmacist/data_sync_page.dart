import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/pharmacist_service.dart';

class DataSyncPage extends ConsumerStatefulWidget {
  const DataSyncPage({super.key});

  @override
  ConsumerState<DataSyncPage> createState() => _DataSyncPageState();
}

class _DataSyncPageState extends ConsumerState<DataSyncPage> {
  String selectedSource = 'longchau';
  bool isSyncing = false;
  String? syncResult;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đồng bộ dữ liệu thuốc'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source Selection
            Text(
              'Chọn nguồn dữ liệu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Long Châu'),
                      subtitle: const Text('Nhà thuốc Long Châu'),
                      value: 'longchau',
                      groupValue: selectedSource,
                      onChanged: (value) {
                        setState(() {
                          selectedSource = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Pharmacity'),
                      subtitle: const Text('Nhà thuốc Pharmacity'),
                      value: 'pharmacity',
                      groupValue: selectedSource,
                      onChanged: (value) {
                        setState(() {
                          selectedSource = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sync Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSyncing ? null : _startSync,
                icon: isSyncing 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: Text(isSyncing ? 'Đang đồng bộ...' : 'Bắt đầu đồng bộ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sync Result
            if (syncResult != null || error != null) ...[
              Text(
                'Kết quả đồng bộ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                color: error != null ? Colors.red[50] : Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            error != null ? Icons.error : Icons.check_circle,
                            color: error != null ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            error != null ? 'Lỗi đồng bộ' : 'Đồng bộ thành công',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: error != null ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error ?? syncResult!,
                        style: TextStyle(
                          color: error != null ? Colors.red[700] : Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Instructions
            Text(
              'Hướng dẫn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInstructionItem(
                      '1',
                      'Chọn nguồn dữ liệu',
                      'Long Châu hoặc Pharmacity',
                    ),
                    _buildInstructionItem(
                      '2',
                      'Nhấn "Bắt đầu đồng bộ"',
                      'Hệ thống sẽ tự động crawl dữ liệu',
                    ),
                    _buildInstructionItem(
                      '3',
                      'Chờ quá trình hoàn tất',
                      'Có thể mất vài phút tùy vào số lượng sản phẩm',
                    ),
                    _buildInstructionItem(
                      '4',
                      'Kiểm tra kết quả',
                      'Xem số lượng sản phẩm được thêm/cập nhật',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Sync History
            Text(
              'Lịch sử đồng bộ',
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
                  _buildSyncHistoryItem(
                    'Long Châu',
                    '2024-01-15 14:30',
                    'Thành công',
                    '1,234 sản phẩm',
                    Colors.green,
                  ),
                  _buildSyncHistoryItem(
                    'Pharmacity',
                    '2024-01-14 09:15',
                    'Thành công',
                    '987 sản phẩm',
                    Colors.green,
                  ),
                  _buildSyncHistoryItem(
                    'Long Châu',
                    '2024-01-13 16:45',
                    'Lỗi',
                    'Kết nối timeout',
                    Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.orange[600],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncHistoryItem(String source, String time, String status, String details, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(
            status == 'Thành công' ? Icons.check_circle : Icons.error,
            color: statusColor,
          ),
        ),
        title: Text('Đồng bộ $source'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(time),
            Text(details),
          ],
        ),
        trailing: Container(
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
      ),
    );
  }

  Future<void> _startSync() async {
    setState(() {
      isSyncing = true;
      error = null;
      syncResult = null;
    });

    try {
      final result = await PharmacistService.syncDrugData(selectedSource);
      
      if (result['success'] == true) {
        setState(() {
          syncResult = result['message'] ?? 'Đồng bộ thành công';
          isSyncing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(syncResult!),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          error = result['message'] ?? 'Lỗi khi đồng bộ dữ liệu';
          isSyncing = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Lỗi kết nối: $e';
        isSyncing = false;
      });
    }
  }
}
