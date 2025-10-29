import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/pharmacist_service.dart';

class QRScannerPage extends ConsumerStatefulWidget {
  const QRScannerPage({super.key});

  @override
  ConsumerState<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends ConsumerState<QRScannerPage> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanning = true;
  Map<String, dynamic>? scannedProduct;
  bool isLoading = false;
  String? error;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (isScanning) {
      final List<Barcode> barcodes = capture.barcodes;
      if (barcodes.isNotEmpty) {
        final barcode = barcodes.first;
        if (barcode.rawValue != null) {
          setState(() {
            isScanning = false;
          });
          _validateQRCode(barcode.rawValue!);
        }
      }
    }
  }

  Future<void> _validateQRCode(String qrCode) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await PharmacistService.validateQRCode(qrCode);

      if (result['success'] == true && result['data']['valid'] == true) {
        setState(() {
          scannedProduct = result['data']['product'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = result['data']['message'] ?? 'Mã QR không hợp lệ';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Lỗi khi kiểm tra mã QR: $e';
        isLoading = false;
      });
    }
  }

  void _resetScanner() {
    setState(() {
      isScanning = true;
      scannedProduct = null;
      error = null;
      isLoading = false;
    });
    controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét mã QR thuốc'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetScanner,
          ),
        ],
      ),
      body: Column(
        children: [
          // QR Scanner
          Expanded(
            flex: 3,
            child: isScanning
                ? MobileScanner(
                    controller: controller,
                    onDetect: _onDetect,
                  )
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 100,
                            color: Colors.white,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Nhấn nút quét lại để tiếp tục',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Result Area
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                      ? _buildErrorWidget()
                      : scannedProduct != null
                          ? _buildProductInfo()
                          : _buildInstructions(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.qr_code_scanner,
          size: 64,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          'Đưa camera vào mã QR trên sản phẩm thuốc để kiểm tra thông tin',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _resetScanner,
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Bắt đầu quét'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[600],
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.red[300],
        ),
        const SizedBox(height: 16),
        Text(
          error!,
          style: TextStyle(
            fontSize: 16,
            color: Colors.red[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _resetScanner,
          icon: const Icon(Icons.refresh),
          label: const Text('Thử lại'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    final product = scannedProduct!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600]),
              const SizedBox(width: 8),
              Text(
                'Mã QR hợp lệ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Không có tên',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (product['category'] != null) ...[
                    Row(
                      children: [
                        Icon(Icons.category, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text('Danh mục: ${product['category']}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text('Giá: ${product['price']?.toString() ?? 'N/A'} VNĐ'),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.inventory, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Tồn kho: ${product['inStock']?.toString() ?? '0'}',
                        style: TextStyle(
                          color: (product['inStock'] ?? 0) <= 10 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  if (product['dosage'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.medication, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Liều lượng: ${product['dosage']}')),
                      ],
                    ),
                  ],

                  if (product['sideEffects'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning, size: 16, color: Colors.orange[600]),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Tác dụng phụ: ${product['sideEffects']}')),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _resetScanner,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Quét tiếp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to product detail or edit
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Chỉnh sửa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
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