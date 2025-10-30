import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/product_service.dart';

class UserQrScannerPage extends StatefulWidget {
  const UserQrScannerPage({super.key});

  @override
  State<UserQrScannerPage> createState() => _UserQrScannerPageState();
}

class _UserQrScannerPageState extends State<UserQrScannerPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  bool _isScanning = true;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        try {
          final result = await ProductService.findProductByQRCode(code);
          if (result['success'] == true) {
            final product = result['data'];
            setState(() { _isScanning = false; });
            if (!mounted) return;
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Sản phẩm'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['name'] ?? 'Không có tên', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (product['price'] != null) Text('Giá: ${product['price']}'),
                    if (product['dosage'] != null) Text('Liều lượng: ${product['dosage']}'),
                    if (product['sideEffects'] != null) Text('Tác dụng phụ: ${product['sideEffects']}'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            );
          } else {
            _showError(result['message'] ?? 'Không tìm thấy sản phẩm');
          }
        } catch (e) {
          _showError('Lỗi khi tra cứu: $e');
        }
      } else {
        _showError('QR Code is empty');
      }
    }
    setState(() { _isProcessing = false; _isScanning = true; });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: MobileScanner(
        controller: _scannerController,
        onDetect: _handleBarcode,
      ),
    );
  }
}
